class StackItemsController < ApplicationController
  rate_limit to: 60, within: 1.minute, only: %i[create update],
    by: -> { current_user.id },
    with: -> { redirect_to stack_path, alert: I18n.t("auth.too_many") }

  def create
    attrs = item_create_params
    profile = current_user.profiles.find(attrs.delete(:profile_id))
    item = profile.stack_items.new(attrs)
    item.position = profile.stack_items.maximum(:position).to_i + 1
    if item.save
      redirect_to stack_path(profile_id: profile.id)
    else
      redirect_to stack_path(profile_id: profile.id), alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    item = owned_item
    if item.update(item_params)
      redirect_to stack_path(profile_id: item.profile_id)
    else
      redirect_to stack_path(profile_id: item.profile_id), alert: item.errors.full_messages.to_sentence
    end
  end

  def destroy
    item = owned_item
    profile_id = item.profile_id
    item.destroy!
    redirect_to stack_path(profile_id: profile_id)
  end

  def icon
    src = owned_item.icon_src
    fetched = src.present? && IconFetch.call(src)
    return head :not_found unless fetched

    body, type = fetched
    expires_in 1.day, public: false
    send_data body, type: type, disposition: :inline
  end

  def reorder
    ids = Array(params[:ids]).map { |id| Integer(id, exception: false) }.compact
    items = current_user.stack_items.where(id: ids).index_by(&:id)
    StackItem.transaction do
      ids.each_with_index do |id, index|
        items[id]&.update_column(:position, index)
      end
    end
    head :ok
  end

  private
    def owned_item
      current_user.stack_items.find(params[:id])
    end

    def item_params
      params.expect(stack_item: [ :category, :choice, :origin, :note, :url, :icon_url ])
    end

    def item_create_params
      params.expect(stack_item: [ :category, :choice, :origin, :note, :url, :icon_url, :profile_id ])
    end
end
