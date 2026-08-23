class ProfilesController < ApplicationController
  include CurrentProfile
  skip_before_action :load_current_profile

  rate_limit to: 30, within: 1.minute, only: %i[create update],
    by: -> { current_user.id },
    with: -> { redirect_to root_path, alert: I18n.t("auth.too_many") }

  def create
    profile = current_user.profiles.new(profile_params)
    profile.position = current_user.profiles.maximum(:position).to_i + 1
    if profile.save
      session[:profile_id] = profile.id
      redirect_to after_profile_path(profile)
    else
      redirect_to after_profile_path(current_user.profiles.ordered.first), alert: profile.errors.full_messages.to_sentence
    end
  end

  def update
    profile = current_user.profiles.find(params[:id])
    if profile.update(profile_params)
      redirect_to after_profile_path(profile)
    else
      redirect_to after_profile_path(profile), alert: profile.errors.full_messages.to_sentence
    end
  end

  def destroy
    profile = current_user.profiles.find(params[:id])
    unless profile.destroyable?
      redirect_to after_profile_path(profile), alert: t("app.last_profile")
      return
    end
    profile.destroy!
    fallback = current_user.profiles.ordered.first
    session[:profile_id] = fallback.id
    redirect_to after_profile_path(fallback)
  end

  private
    def profile_params
      params.expect(profile: [ :name ])
    end
end
