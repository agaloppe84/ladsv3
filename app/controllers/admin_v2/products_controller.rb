class AdminV2::ProductsController < AdminV2::BaseController
  def index
    @categories = Category.order(:name)
    @products = Product.where(type: nil)
                       .includes(:category, images_attachments: :blob)
                       .order(updated_at: :desc)

    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.where("products.name ILIKE ?", "%#{params[:query]}%") if params[:query].present?
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
