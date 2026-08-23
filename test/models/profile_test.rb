require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
  end

  test "the last profile cannot be destroyed" do
    profile = @user.profiles.first
    refute profile.destroyable?
  end

  test "a second profile can be destroyed" do
    extra = @user.profiles.create!(name: "Work")
    assert extra.destroyable?
    extra.destroy!
    assert_equal 1, @user.profiles.count
  end

  test "names are unique per user" do
    @user.profiles.create!(name: "Work")
    taken = @user.profiles.new(name: "work")
    refute taken.valid?
  end
end
