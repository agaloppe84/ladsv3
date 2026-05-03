class AdminV2::ProductsController < AdminV2::BaseController
  def index
    @categories = Category.order(:name)
    base_scope = Product.where(type: nil)

    @total_products = base_scope.count
    @products = base_scope.includes(:category, :options, images_attachments: :blob, documentations_attachments: :blob)
                          .order(updated_at: :desc)

    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

    query = params[:query].to_s.strip
    @products = @products.where("products.name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%") if query.present?
  end

  def show
    @product = Product.includes(:category, images_attachments: :blob).find(params[:id])
  end

  def edit
    @product = Product.find(params[:id])
    @product.build_service unless @product.service
    @categories = Category.order(:name)
  end
end
