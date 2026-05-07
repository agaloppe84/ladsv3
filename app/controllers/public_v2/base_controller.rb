class PublicV2::BaseController < ApplicationController
  layout "public_v2"

  before_action :load_public_v2_shell_context

  helper_method :public_v2_primary_image, :public_v2_debug?

  private

  def public_v2_primary_image(product)
    return if product.blank?

    attachments = product.images_attachments
    ordered_attachments =
      if attachments.loaded?
        attachments.to_a
      else
        product.ordered_images.to_a
      end

    ordered_attachments.compact.sort_by { |attachment| [attachment.position || 999_999, attachment.id || 0] }.first
  end

  def active_event
    Event.where("start_date <= :now AND end_date >= :now", now: Time.current)
         .order(start_date: :desc, updated_at: :desc)
         .first
  end

  def public_products
    Product.joins(:category).merge(Category.published).where(type: nil)
  end

  def public_categories
    Category.published.order(:name)
  end

  def public_destock_products
    DestockProduct.joins(:category).merge(Category.published)
  end

  def public_product_cards
    public_products.includes(
      :category,
      :manufacturers,
      { images_attachments: :blob }
    )
  end

  def public_product_details
    public_products.includes(
      :category,
      :manufacturers,
      :motorists,
      :options,
      :service,
      { images_attachments: :blob },
      { documentations_attachments: :blob }
    )
  end

  def product_counts_for(category_ids)
    return {} if category_ids.blank?

    Product.where(type: nil, category_id: category_ids).group(:category_id).count
  end

  def category_cover_products_for(category_ids)
    return {} if category_ids.blank?

    Product.where(type: nil, category_id: category_ids)
           .select("DISTINCT ON (products.category_id) products.*")
           .includes(images_attachments: :blob)
           .order(Arel.sql("products.category_id ASC, products.name ASC, products.id ASC"))
           .each_with_object({}) do |product, cover_products|
             cover_products[product.category_id] ||= product
           end
  end

  def load_public_v2_shell_context
    @public_v2_debug = true
    @event = active_event
    @public_v2_footer_categories = public_categories.limit(5).to_a
    @public_v2_active_nav_key = public_v2_active_nav_key
    @public_v2_show_mode_toggle = true
  end

  def public_v2_debug?
    @public_v2_debug == true
  end

  def public_v2_active_nav_key
    return :home if controller_name == "pages" && action_name == "home"
    return :contact if controller_name == "pages" && action_name == "contact"
    return :products if controller_name.in?(%w[categories products])
    return :quote if controller_name == "quotes"

    nil
  end
end
