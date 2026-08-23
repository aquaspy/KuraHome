class Profile < ApplicationRecord
  MAX_PER_USER = 12

  belongs_to :user
  has_many :sites, dependent: :destroy
  has_many :stack_items, dependent: :destroy

  normalizes :name, with: -> { it.to_s.strip.gsub(/\s+/, " ") }

  validates :name, presence: true, length: { maximum: 40 }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
  validate :within_cap, on: :create

  scope :ordered, -> { order(:position, :id) }

  def destroyable?
    user.profiles.where.not(id: id).exists?
  end

  private
    def within_cap
      return if user.blank?
      errors.add(:base, :too_many_profiles) if user.profiles.count >= MAX_PER_USER
    end
end
