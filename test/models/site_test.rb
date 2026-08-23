require "test_helper"

class SiteTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
    @profile = @user.profiles.first
  end

  test "adds https and fills a blank title from the host" do
    site = @profile.sites.create!(url: "example.com")
    assert_equal "https://example.com", site.url
    assert_equal "example.com", site.title
    assert_equal "E", site.letter
  end

  test "rejects javascript urls" do
    site = @profile.sites.new(title: "Nope", url: "javascript:alert(1)")
    refute site.valid?
    assert site.errors[:url].any?
  end

  test "strips www from the shown host" do
    site = @profile.sites.create!(title: "School", url: "https://www.faculdade.edu.br/portal")
    assert_equal "faculdade.edu.br", site.host
  end

  test "pulls a favicon from the host and allows an override" do
    site = @profile.sites.create!(title: "School", url: "https://www.faculdade.edu.br")
    assert_includes site.icon_src, "faculdade.edu.br"
    site.update!(icon_url: "https://example.com/icon.png")
    assert_equal "https://example.com/icon.png", site.icon_src
  end
end
