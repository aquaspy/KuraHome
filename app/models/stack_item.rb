class StackItem < ApplicationRecord
  include HasIcon

  MAX_PER_PROFILE = 80

  belongs_to :profile

  normalizes :category, with: -> { it.to_s.strip.gsub(/\s+/, " ") }
  normalizes :choice, with: -> { it.to_s.strip.gsub(/\s+/, " ") }
  normalizes :origin, with: -> { it.to_s.strip.gsub(/\s+/, " ") }
  normalizes :note, with: -> { it.to_s.strip.gsub(/\s+/, " ") }

  before_validation :normalize_url

  validates :category, presence: true, length: { maximum: 60 }
  validates :choice, presence: true, length: { maximum: 80 }
  validates :origin, length: { maximum: 80 }
  validates :note, length: { maximum: 160 }
  validates :url, length: { maximum: 2048 }
  validate :http_url_if_present
  validate :within_cap, on: :create

  scope :ordered, -> { order(:position, :id) }

  def linked?
    url.present?
  end

  private
    def normalize_url
      raw = url.to_s.strip
      if raw.blank?
        self.url = ""
        return
      end
      raw = "https://#{raw}" unless raw.match?(/\A[a-z][a-z0-9+.-]*:\/\//i)
      self.url = raw
    end

    def http_url_if_present
      return if url.blank?

      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.blank?
        errors.add(:url, :invalid)
      end
    rescue URI::InvalidURIError
      errors.add(:url, :invalid)
    end

    def within_cap
      return if profile.blank?
      errors.add(:base, :too_many_stack_items) if profile.stack_items.count >= MAX_PER_PROFILE
    end
end
