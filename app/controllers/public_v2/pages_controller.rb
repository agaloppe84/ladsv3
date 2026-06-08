class PublicV2::PagesController < PublicV2::BaseController
  def home
    @home_page = build_home_page
  end

  def contact
    @contact_page = build_contact_page
  end

  private

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

  def build_contact_page
    PublicV2::ContactPage.new(
      categories: public_categories.limit(8).to_a,
      product_count: public_products.count + public_destock_products.count
    )
  end

end
