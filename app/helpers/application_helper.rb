module ApplicationHelper
  def signup_enabled?
    Kura.signup_enabled?
  end

  def stack_page?
    controller_name == "home" && action_name == "stack"
  end

  def profile_href(profile)
    stack_page? ? stack_path(profile_id: profile.id) : root_path(profile_id: profile.id)
  end
end
