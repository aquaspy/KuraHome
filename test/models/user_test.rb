require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email and requires a long enough password" do
    user = User.create!(email: "  Ada@Example.com ", password: "secret-password")
    assert_equal "ada@example.com", user.email
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create!(email: "other@example.com", password: "short")
    end
  end

  test "seeds a home profile" do
    user = User.create!(email: "lin@example.com", password: "secret-password")
    assert_equal 1, user.profiles.count
    assert_equal I18n.t("app.default_profile"), user.profiles.first.name
  end
end
