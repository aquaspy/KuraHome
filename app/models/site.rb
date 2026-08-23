class Site < ApplicationRecord
  include HasIcon

  MAX_PER_PROFILE = 60

  belongs_to :profile

  normalizes :title, with: -> { it.to_s.strip.gsub(/\s+/, " ") }
  normalizes :hint, with: -> { it.to_s.strip.gsub(/\s+/, " ") }

  before_validation :normalize_url
  before_validation :fill_title

  validates :title, presence: true, length: { maximum: 80 }
  validates :url, presence: true, length: { maximum: 2048 }
  validates :hint, length: { maximum: 120 }
  validate :http_url
  validate :within_cap, on: :create

  scope :ordered, -> { order(:position, :id) }

  private
    def normalize_url
      raw = url.to_s.strip
      return if raw.blank?
      raw = "https://#{raw}" unless raw.match?(/\A[a-z][a-z0-9+.-]*:\/\//i)
      self.url = raw
    end

    def fill_title
      self.title = host if title.blank? && host.present?
    end

    def http_url
      uri = URI.parse(url.to_s)
      unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.blank?
        errors.add(:url, :invalid)
      end
    rescue URI::InvalidURIError
      errors.add(:url, :invalid)
    end

    def within_cap
      return if profile.blank?
      errors.add(:base, :too_many_sites) if profile.sites.count >= MAX_PER_PROFILE
    end
end
