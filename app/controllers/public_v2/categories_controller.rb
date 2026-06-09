class PublicV2::CategoriesController < PublicV2::BaseController
  def index
    categories = public_categories.to_a

    category_ids = categories.map(&:id)
    products_by_category_id = public_category_index_products
                              .where(category_id: category_ids)
                              .order(:name)
                              .to_a
                              .group_by(&:category_id)

    @category_index_page = PublicV2::CategoryIndexPage.new(
      categories: categories,
      product_counts: product_counts_for(category_ids),
      cover_products: category_cover_products_for(category_ids),
      products_by_category_id: products_by_category_id,
      primary_image_resolver: method(:public_v2_primary_image),
      product_path_builder: ->(product) { public_v2_product_path(slug: product.slug) }
    )
  end

  private

  def public_category_index_products
    public_products.includes(
      :category,
      { front_image_attachment: :blob },
      { images_attachments: :blob }
    )
  end
end
