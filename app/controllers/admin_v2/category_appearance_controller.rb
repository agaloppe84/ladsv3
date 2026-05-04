class AdminV2::CategoryAppearanceController < AdminV2::CategoryScopedController
  def update
    @category.assign_attributes(category_params)

    unless allowed_color?(@category.color)
      @category.errors.add(:color, "n'est pas disponible dans la palette V2")
    end

    if @category.errors.empty? && @category.save
      render_category_streams(
        category_row_stream,
        drawer_header_stream,
        level: :success,
        message: "Category##{@category.id} color updated",
        event_type: :autosave
      )
    else
      render_category_streams(
        appearance_panel_stream,
        level: :warning,
        message: @category.errors.full_messages.to_sentence.presence || "Category color invalid",
        event_type: :error,
        status: :unprocessable_entity
      )
    end
  end

  private

  def category_params
    params.require(:category).permit(:color)
  end

  def allowed_color?(color)
    color.blank? || AdminV2::Categories::ColorPalette.values.include?(color)
  end
end
