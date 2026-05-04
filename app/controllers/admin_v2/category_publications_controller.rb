class AdminV2::CategoryPublicationsController < AdminV2::CategoryScopedController
  PUBLICATION_PRODUCT_ERROR = "Ajoute au moins un produit valide avant de publier cette catégorie."

  def update
    @category.assign_attributes(category_params)
    validate_publication_requirements

    if @category.errors.empty? && @category.save
      render_category_streams(
        category_row_stream,
        drawer_header_stream,
        publication_panel_stream,
        level: :success,
        message: publication_message,
        event_type: :autosave
      )
    else
      render_category_streams(
        publication_panel_stream,
        level: :warning,
        message: publication_error_message,
        event_type: :error,
        status: :unprocessable_entity
      )
    end
  end

  private

  def category_params
    params.require(:category).permit(:active)
  end

  def validate_publication_requirements
    return unless @category.active?
    return if valid_store_product_exists?

    @category.errors.add(:active, PUBLICATION_PRODUCT_ERROR)
    @category.active = @category.active_in_database
  end

  def valid_store_product_exists?
    @category
      .products
      .where(type: nil)
      .where.not(name: [nil, ""])
      .where.not(slug: [nil, ""])
      .exists?
  end

  def publication_message
    state = @category.active? ? "published" : "unpublished"
    "Category##{@category.id} #{state}"
  end

  def publication_error_message
    @category.errors[:active].to_sentence.presence || "Category publication invalid"
  end
end
