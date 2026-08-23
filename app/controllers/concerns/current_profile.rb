module CurrentProfile
  extend ActiveSupport::Concern

  included do
    before_action :load_current_profile
  end

  private
    def load_current_profile
      @profiles = current_user.profiles.ordered.to_a
      if @profiles.empty?
        current_user.profiles.create!(name: I18n.t("app.default_profile"), position: 0)
        @profiles = current_user.profiles.ordered.to_a
      end
      @profile = pick_profile
    end

    def pick_profile
      id = params[:profile_id].presence || session[:profile_id]
      found = @profiles.find { |profile| profile.id.to_s == id.to_s } if id
      profile = found || @profiles.first
      session[:profile_id] = profile.id
      profile
    end

    def after_profile_path(profile)
      if request.referer.to_s.match?(%r{/stack(\?|$)})
        stack_path(profile_id: profile.id)
      else
        root_path(profile_id: profile.id)
      end
    end
end
