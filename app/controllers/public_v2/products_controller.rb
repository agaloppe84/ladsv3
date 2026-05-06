class PublicV2::ProductsController < PublicV2::BaseController
  def show
    product = public_product_details.find_by!(slug: params[:slug])
    color_parts = product.product_color_parts
                         .includes(color_palette: { color_palette_items: [:ral, :finish] })
                         .order(:created_at)
                         .to_a
    related_products = public_product_cards
                       .where(category_id: product.category_id)
                       .where.not(id: product.id)
                       .order(:name)
                       .limit(4)
                       .to_a

    @product_page = PublicV2::ProductPage.new(
      product: product,
      category: product.category,
      color_parts: color_parts,
      related_products: related_products,
      primary_image_resolver: method(:public_v2_primary_image),
      product_path_builder: ->(related_product) { public_v2_product_path(slug: related_product.slug) },
      home_path: public_v2_home_path,
      catalog_path: public_v2_categories_path,
      quote_path: public_v2_new_quote_path(product_id: product.id)
    )
  end
end
