module HasIcon
  extend ActiveSupport::Concern

  PALETTE = %w[#b55220 #3d6b5a #5c4a7a #7a4a3a #3a5a7a #6b5a3d #7a5c2e #4a6b4a].freeze

  included do
    normalizes :icon_url, with: -> { it.to_s.strip }
    before_validation :normalize_icon_url
    validates :icon_url, length: { maximum: 2048 }
    validate :http_icon_if_present
  end

  def host
    URI.parse(url.to_s).host.to_s.sub(/\Awww\./i, "")
  rescue URI::InvalidURIError
    ""
  end

  def letter
    label = (try(:title) || try(:choice)).to_s
    (label.gsub(/[^\p{Alnum}]/, "").chars.first || host.chars.first || "?").upcase
  end

  def color
    PALETTE[(host.presence || letter).each_byte.sum % PALETTE.size]
  end

  def icon_src
    return icon_url if icon_url.present?
    return if host.blank?

    "https://icons.duckduckgo.com/ip3/#{host}.ico"
  end

  private
    def normalize_icon_url
      raw = icon_url.to_s.strip
      if raw.blank?
        self.icon_url = ""
        return
      end
      raw = "https://#{raw}" unless raw.match?(/\A[a-z][a-z0-9+.-]*:\/\//i)
      self.icon_url = raw
    end

    def http_icon_if_present
      return if icon_url.blank?

      uri = URI.parse(icon_url)
      unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.blank?
        errors.add(:icon_url, :invalid)
      end
    rescue URI::InvalidURIError
      errors.add(:icon_url, :invalid)
    end
end
