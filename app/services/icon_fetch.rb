require "ipaddr"
require "net/http"

module IconFetch
  module_function

  TIMEOUT = 2
  MAX = 64 * 1024
  CACHE_TTL = 1.day

  def call(url)
    key = [ "icon", Digest::SHA256.hexdigest(url.to_s) ]
    cached = Rails.cache.read(key)
    return cached if cached

    result = download(url)
    Rails.cache.write(key, result, expires_in: CACHE_TTL) if result
    result
  end

  def download(url)
    uri = URI.parse(url.to_s)
    return unless uri.is_a?(URI::HTTP)
    return if uri.userinfo.present? || uri.host.blank? || private_host?(uri.host)

    body = +""
    Net::HTTP.start(uri.host, uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: TIMEOUT,
      read_timeout: TIMEOUT) do |http|
      http.request_get(uri.request_uri) do |response|
        return unless response.is_a?(Net::HTTPSuccess)

        response.read_body do |chunk|
          body << chunk
          return if body.bytesize > MAX
        end
        type = response["content-type"].to_s.split(";").first.presence || "image/png"
        return [ body.dup, type ]
      end
    end
  rescue StandardError
    nil
  end

  def private_host?(host)
    name = host.to_s.downcase
    return true if name == "localhost" || name.end_with?(".localhost") || name == "unix"

    ip = IPAddr.new(name)
    ip.loopback? || ip.private? || ip.link_local?
  rescue IPAddr::Error
    false
  end
end
