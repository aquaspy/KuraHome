require "test_helper"

class StackItemTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
    @profile = @user.profiles.first
  end

  test "allows a blank url and fills https when a host is given" do
    item = @profile.stack_items.create!(category: "Music", choice: "Tidal", origin: "USA / Norway", note: "Good pick")
    assert_equal "", item.url
    refute item.linked?

    item.update!(url: "tidal.com")
    assert_equal "https://tidal.com", item.url
    assert item.linked?
  end

  test "rejects javascript urls even when optional" do
    item = @profile.stack_items.new(category: "Browser", choice: "Nope", url: "javascript:alert(1)")
    refute item.valid?
    assert item.errors[:url].any?
  end

  test "uses the linked host for a favicon" do
    item = @profile.stack_items.create!(category: "Music", choice: "Tidal", url: "tidal.com")
    assert_includes item.icon_src, "tidal.com"
    assert_equal "T", item.letter
  end
end
