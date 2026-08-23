require "test_helper"

class HomeFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com", password: "secret-password")
  end

  test "signup can be turned off" do
    ENV["SIGNUP_ENABLED"] = "false"
    get signup_path
    assert_redirected_to login_path
    follow_redirect!
    refute_includes response.body, I18n.t("auth.create_one")

    assert_no_difference -> { User.count } do
      post signup_path, params: { email: "intruder@example.com", password: "secret-password", password_confirmation: "secret-password" }
    end
    assert_redirected_to login_path
  ensure
    ENV.delete("SIGNUP_ENABLED")
  end

  test "signup creates a user with a home profile" do
    post signup_path, params: { email: "lin@example.com", password: "secret-password", password_confirmation: "secret-password" }
    assert_redirected_to root_path
    user = User.find_by(email: "lin@example.com")
    assert user
    assert user.authenticate("secret-password")
    assert_equal 1, user.profiles.count
  end

  test "login opens the home page" do
    post login_path, params: { email: @user.email, password: "secret-password" }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_includes response.body, "KuraHome"
    assert_includes response.body, @user.profiles.first.name
    assert_select "[data-edit-target=label]"
  end

  test "strangers cannot read the home" do
    get root_path
    assert_redirected_to login_path
  end

  test "a user can add a profile and a site" do
    login
    assert_difference -> { @user.profiles.count }, 1 do
      post profiles_path, params: { profile: { name: "Work" } }
    end
    work = @user.profiles.find_by!(name: "Work")
    assert_redirected_to root_path(profile_id: work.id)

    assert_difference -> { work.sites.count }, 1 do
      post sites_path, params: { site: { profile_id: work.id, title: "Faculty", url: "faculdade.edu.br", hint: "Portal" } }
    end
    follow_redirect!
    site = work.sites.last
    assert_equal "https://faculdade.edu.br", site.url
    assert_includes response.body, "Faculty"
    assert_includes response.body, "Portal"
    assert_select "a.tile[href='https://faculdade.edu.br']"
    assert_select "img.mark-favicon[src*='faculdade.edu.br']"
    assert_select ".tile-edit.is-danger"
  end

  test "sites can be reordered" do
    login
    profile = @user.profiles.first
    first = profile.sites.create!(title: "A", url: "https://a.example", position: 0)
    second = profile.sites.create!(title: "B", url: "https://b.example", position: 1)
    patch reorder_sites_path, params: { ids: [ second.id, first.id ] }
    assert_response :success
    assert_equal [ second.id, first.id ], profile.sites.ordered.pluck(:id)
  end

  test "another user cannot touch a site" do
    login
    profile = @user.profiles.first
    site = profile.sites.create!(title: "Mine", url: "https://example.com")
    delete logout_path

    other = User.create!(email: "other@example.com", password: "secret-password")
    post login_path, params: { email: other.email, password: "secret-password" }

    patch site_path(site), params: { site: { title: "Stolen" } }
    assert_response :not_found
    assert_equal "Mine", site.reload.title

    delete site_path(site)
    assert_response :not_found
    assert Site.exists?(site.id)
  end

  test "the last profile cannot be deleted" do
    login
    profile = @user.profiles.first
    delete profile_path(profile)
    assert_redirected_to root_path(profile_id: profile.id)
    follow_redirect!
    assert_includes response.body, I18n.t("app.last_profile")
    assert Profile.exists?(profile.id)
  end

  test "lock hides the home until unlocked" do
    login
    @user.profiles.first.sites.create!(title: "Hidden after lock", url: "https://example.com")
    post lock_path
    assert_redirected_to unlock_path
    follow_redirect!
    assert_response :success
    refute_includes response.body, "Hidden after lock"

    get root_path
    assert_redirected_to unlock_path

    post unlock_path, params: { password: "wrong-password" }
    assert_response :unprocessable_entity

    post unlock_path, params: { password: "secret-password" }
    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Hidden after lock"
  end

  test "ui language follows Accept-Language" do
    get login_path, headers: { "Accept-Language" => "pt-BR,pt;q=0.9" }
    assert_includes response.body, "Entrar"
    assert_includes response.body, 'lang="pt-BR"'

    get login_path, headers: { "Accept-Language" => "en-US,en;q=0.8" }
    assert_includes response.body, "Sign in"
    assert_includes response.body, 'lang="en"'
  end

  test "session cookie lasts until sign out" do
    assert_equal 20.years, Rails.application.config.session_options[:expire_after]
  end

  test "site fields are filtered from request logs" do
    filtered = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      .filter({ "site" => { "title" => "Faculty", "url" => "https://secret.example", "hint" => "portal" }, "name" => "Work" })

    assert_equal "[FILTERED]", filtered.dig("site", "title")
    assert_equal "[FILTERED]", filtered.dig("site", "url")
    assert_equal "[FILTERED]", filtered.dig("site", "hint")
    assert_equal "[FILTERED]", filtered["name"]
  end

  test "auto lock is off by default and can be toggled" do
    login
    assert_not @user.reload.auto_lock?

    get root_path
    assert_includes response.body, "Turn on auto lock"
    assert_not_includes response.body, "Turn off auto lock"

    travel 20.minutes do
      get root_path
      assert_response :success
    end

    post auto_lock_path
    follow_redirect!
    assert @user.reload.auto_lock?
    assert_includes response.body, "Turn off auto lock"

    travel 20.minutes do
      get root_path
      assert_redirected_to unlock_path
    end
  end

  test "logged in user can change password" do
    login
    get root_path
    assert_includes response.body, "Change password"

    patch password_path, params: { current_password: "secret-password", password: "new-secret", password_confirmation: "new-secret" }
    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Password changed."
    assert @user.reload.authenticate("new-secret")

    delete logout_path
    post login_path, params: { email: @user.email, password: "secret-password" }
    assert_response :unprocessable_entity
    post login_path, params: { email: @user.email, password: "new-secret" }
    assert_redirected_to root_path
  end

  test "portuguese home labels" do
    login
    get root_path, headers: { "Accept-Language" => "pt-BR,pt;q=0.9" }
    assert_includes response.body, "Adicionar site"
    assert_includes response.body, "Editar"
    assert_not_includes response.body, "Add a site"
  end

  test "stack lives on its own page per profile" do
    login
    get stack_path
    assert_response :success
    assert_includes response.body, "My stack"
    assert_includes response.body, I18n.t("app.stack_empty_title")
    assert_select "a.view-tab.is-on", text: "Stack"

    profile = @user.profiles.first
    assert_difference -> { profile.stack_items.count }, 1 do
      post stack_items_path, params: {
        stack_item: {
          profile_id: profile.id,
          category: "Music",
          choice: "Tidal",
          origin: "USA / Norway",
          note: "Good pick",
          url: "tidal.com"
        }
      }
    end
    assert_redirected_to stack_path(profile_id: profile.id)
    follow_redirect!
    item = profile.stack_items.last
    assert_equal "https://tidal.com", item.url
    assert_includes response.body, "Tidal"
    assert_includes response.body, "USA / Norway"
    assert_select "a[href='https://tidal.com']", text: "Tidal"
    assert_select "img.mark-favicon[src*='tidal.com']"
    assert_select "button.share-btn"
    assert_select ".row-edit.is-danger"
    assert_select "[data-controller='share']"
    assert_includes response.body, icon_stack_item_path(item)
  end

  test "another user cannot touch a stack item" do
    login
    item = @user.profiles.first.stack_items.create!(category: "VPN", choice: "Mine")
    delete logout_path

    other = User.create!(email: "other@example.com", password: "secret-password")
    post login_path, params: { email: other.email, password: "secret-password" }

    patch stack_item_path(item), params: { stack_item: { choice: "Stolen" } }
    assert_response :not_found
    assert_equal "Mine", item.reload.choice

    get icon_stack_item_path(item)
    assert_response :not_found
  end

  test "switching profiles on stack stays on stack" do
    login
    work = @user.profiles.create!(name: "Work")
    work.stack_items.create!(category: "Email", choice: "Mailcow", origin: "Germany")
    get stack_path(profile_id: work.id)
    assert_response :success
    assert_includes response.body, "Mailcow"
    assert_select "a.profile-tab.is-on", text: "Work"
    assert_select "a.profile-tab[href=?]", stack_path(profile_id: work.id)
  end

  test "service worker is network first and wipes on logout" do
    get pwa_service_worker_path(format: :js)
    assert_response :success
    assert_includes response.body, 'const CACHE = "kurahome-v1"'
    assert_includes response.body, "cache.put"
    login
    follow_redirect!
    assert_select "[data-controller='logout']"
  end

  private
    def login
      post login_path, params: { email: @user.email, password: "secret-password" }
      assert_redirected_to root_path
    end
end
