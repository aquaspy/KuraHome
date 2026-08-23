class SitesController < ApplicationController
  rate_limit to: 60, within: 1.minute, only: %i[create update],
    by: -> { current_user.id },
    with: -> { redirect_to root_path, alert: I18n.t("auth.too_many") }

  def create
    attrs = site_create_params
    profile = current_user.profiles.find(attrs.delete(:profile_id))
    site = profile.sites.new(attrs)
    site.position = profile.sites.maximum(:position).to_i + 1
    if site.save
      redirect_to root_path(profile_id: profile.id)
    else
      redirect_to root_path(profile_id: profile.id), alert: site.errors.full_messages.to_sentence
    end
  end

  def update
    site = owned_site
    if site.update(site_params)
      redirect_to root_path(profile_id: site.profile_id)
    else
      redirect_to root_path(profile_id: site.profile_id), alert: site.errors.full_messages.to_sentence
    end
  end

  def destroy
    site = owned_site
    profile_id = site.profile_id
    site.destroy!
    redirect_to root_path(profile_id: profile_id)
  end

  def reorder
    ids = Array(params[:ids]).map { |id| Integer(id, exception: false) }.compact
    sites = current_user.sites.where(id: ids).index_by(&:id)
    Site.transaction do
      ids.each_with_index do |id, index|
        sites[id]&.update_column(:position, index)
      end
    end
    head :ok
  end

  private
    def owned_site
      current_user.sites.find(params[:id])
    end

    def site_params
      params.expect(site: [ :title, :url, :hint, :icon_url ])
    end

    def site_create_params
      params.expect(site: [ :title, :url, :hint, :icon_url, :profile_id ])
    end
end
