class AdminV2::CategoryDetailsController < AdminV2::CategoryScopedController
  def update
    permitted_params = category_params
    @category.assign_attributes(permitted_params)
    @category.errors.add(:name, "doit être renseigné") if permitted_params.key?(:name) && @category.name.blank?

    if @category.errors.empty? && @category.save
      render_category_streams(
        category_row_stream,
        drawer_header_stream,
        level: :success,
        message: detail_message(permitted_params),
        event_type: :autosave
      )
    else
      render_category_streams(
        details_panel_stream,
        level: :warning,
        message: @category.errors.full_messages.to_sentence.presence || "Category details invalid",
        event_type: :error,
        status: :unprocessable_entity
      )
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end

  def detail_message(permitted_params)
    field = permitted_params.keys.first.to_s.presence || "details"
    "Category##{@category.id} #{field} updated"
  end
end
