class PublicV2::PagesController < PublicV2::BaseController
  def home
    @home_page = build_home_page
  end

  def home_test
    @home_test = PublicV2::HomeTestPage.new
  end

  def layouts_test
    @public_v2_show_theme = false
    @layouts_test = PublicV2::LayoutsTestPage.new
  end

  def design_system
    categories = public_categories.limit(8).to_a
    products = public_product_cards.order(updated_at: :desc).limit(8).to_a
    featured_product = products.find { |product| public_v2_primary_image(product).present? } || products.first
    destock_products = public_destock_products.includes(:category, images_attachments: :blob)
                                             .order(updated_at: :desc)
                                             .limit(2)
                                             .to_a

    @design_system = PublicV2::DesignSystemPage.new(
      categories: categories,
      products: products,
      destock_products: destock_products,
      featured_product: featured_product,
      primary_image_resolver: method(:public_v2_primary_image),
      path_builder: method(:public_v2_design_system_path_for)
    )
  end

  def contact
  end

  private

  def public_v2_design_system_path_for(path_key)
    {
      home: public_v2_home_path,
      categories: public_v2_categories_path,
      quote: public_v2_new_quote_path,
      contact: public_v2_contact_path
    }.fetch(path_key)
  end

  def build_home_page
    categories = public_categories.limit(8).to_a
    category_ids = categories.map(&:id)
    products = public_product_cards.order(updated_at: :desc).limit(8).to_a
    destock_products = public_destock_products.includes(:category, :options, images_attachments: :blob)
                                             .order(updated_at: :desc)
                                             .limit(4)
                                             .to_a
    featured_product = products.find { |product| public_v2_primary_image(product).present? } || products.first

    PublicV2::HomePage.new(
      categories: categories,
      products: products,
      destock_products: destock_products,
      featured_product: featured_product,
      category_product_counts: product_counts_for(category_ids),
      category_cover_products: category_cover_products_for(category_ids),
      primary_image_resolver: method(:public_v2_primary_image)
    )
  end
end
