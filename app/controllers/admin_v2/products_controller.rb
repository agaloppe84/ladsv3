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

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          store_nav_stream(:products),
          turbo_stream.replace(
            "admin_v2_main",
            partial: "admin_v2/products/index_frame",
            locals: { products: @products, total_products: @total_products }
          )
        ]
      end
    end
  end

  def show
    @product = Product.includes(:category, images_attachments: :blob).find(params[:id])
  end

  def new
    @product = Product.new(warranty: 7)
    @categories = Category.order(:name)
  end

  def create
    @product = Product.new(product_params)
    @categories = Category.order(:name)

    @product.errors.add(:name, "doit être renseigné") if @product.name.blank?

    if @product.errors.empty? && @product.save
      @product.build_service unless @product.service

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "admin_v2_main",
              partial: "admin_v2/products/edit_frame",
              locals: { product: @product, categories: @categories }
            ),
            turbo_stream.replace(
              "admin_v2_drawer",
              partial: "admin_v2/products/drawer_frame",
              locals: { product: @product }
            ),
            store_nav_stream(:products),
            turbo_stream_flash(:success, "Product##{@product.id} created")
          ]
        end
        format.html { redirect_to edit_admin_v2_product_path(@product), notice: "Produit créé" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, formats: :html, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @product = Product.find(params[:id])
    @product.build_service unless @product.service
    @categories = Category.order(:name)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "admin_v2_main",
            partial: "admin_v2/products/edit_frame",
            locals: { product: @product, categories: @categories }
          ),
          turbo_stream.replace(
            "admin_v2_drawer",
            partial: "admin_v2/products/drawer_frame",
            locals: { product: @product }
          ),
          store_nav_stream(:products)
        ]
      end
      format.html
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :category_id, :description, :infos, :warranty)
  end
end
