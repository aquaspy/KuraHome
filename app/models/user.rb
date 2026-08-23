class User < ApplicationRecord
  has_secure_password
  has_many :profiles, dependent: :destroy
  has_many :sites, through: :profiles
  has_many :stack_items, through: :profiles

  normalizes :email, with: -> { it.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  after_create :seed_home_profile

  private
    def seed_home_profile
      profiles.create!(name: I18n.t("app.default_profile"), position: 0)
    end
end
