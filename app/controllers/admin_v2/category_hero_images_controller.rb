class AdminV2::CategoryHeroImagesController < AdminV2::CategoryScopedController
  def create
    attach_category_upload(
      field: :category_hero_image,
      attachment: @category.hero_image,
      success_message: "Category##{@category.id} hero image attached"
    ) do
      [hero_image_panel_stream, drawer_summary_stream]
    end
  end

  def destroy
    @category.hero_image.purge if @category.hero_image.attached?

    render_category_streams(
      hero_image_panel_stream,
      drawer_summary_stream,
      level: :success,
      message: "Category##{@category.id} hero image removed",
      event_type: :delete
    )
  end
end
