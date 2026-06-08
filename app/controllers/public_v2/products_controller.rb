class PublicV2::ProductsController < PublicV2::BaseController
  DICKSON_SELECTOR_URL = "https://www.dicksondesigner.com/fr/?code=fa20cd8b2281f8a585592eaab2e053b3".freeze

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
      quote_path: public_v2_new_quote_path(product_id: product.id),
      dickson_configurator_path: public_v2_canvas_selector_product_path(slug: product.slug)
    )
  end

  def canvas_selector
    @product = public_product_details.find_by!(slug: params[:slug])
    @canvas_selector_url = DICKSON_SELECTOR_URL
    @canvas_selector_breadcrumb_items = [
      { label: "Accueil", path: public_v2_home_path },
      { label: "Produits", path: public_v2_categories_path },
      { label: @product.name, path: public_v2_product_path(slug: @product.slug) },
      { label: "Selecteur de toile" }
    ]
  end
end
