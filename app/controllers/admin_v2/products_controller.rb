class AdminV2::ProductsController < AdminV2::BaseController
  def index
    load_products_index

    respond_to do |format|
      format.html do
        if products_results_frame_request?
          render partial: "admin_v2/products/results_frame", locals: { products: @products, pagination: @pagination }, layout: false
        else
          render
        end
      end
      format.turbo_stream do
        render turbo_stream: products_index_stream
      end
    end
  end

  def show
    @product = Product.includes(:category, images_attachments: :blob).find(params[:id])
    track_admin_v2_context(@product)
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
            *admin_v2_feedback_streams(:success, "Product##{@product.id} created", event_type: :create, resource: @product, status_code: 200)
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
    track_admin_v2_context(@product)

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

  def destroy
    @product = products_scope.find(params[:id])
    result = AdminV2::ProductDestroyer.new(@product).destroy!
    load_products_index

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "admin_v2_main",
            partial: "admin_v2/products/index_frame",
            locals: { products: @products, total_products: @total_products, pagination: @pagination }
          ),
          deleted_product_drawer_stream(result),
          store_nav_stream(:products),
          *admin_v2_feedback_streams(
            :success,
            product_deleted_message(result),
            event_type: :delete,
            metadata: { source: "cleanup", resource_type: "Product", resource_id: result.product_id },
            status_code: 200
          )
        ].compact
      end
      format.html { redirect_to admin_v2_products_path, notice: "Produit supprimé" }
    end
  rescue ActiveRecord::ActiveRecordError => e
    record = e.respond_to?(:record) ? e.record : nil

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: admin_v2_feedback_streams(
          :error,
          record&.errors&.full_messages&.to_sentence.presence || "Product delete failed",
          event_type: :error,
          resource: @product,
          metadata: { source: "cleanup" },
          status_code: 422
        ), status: :unprocessable_entity
      end
      format.html { redirect_to admin_v2_products_path, alert: "Suppression impossible" }
    end
  end

  private

  def load_products_index
    @categories = Category.order(:name)
    base_scope = products_scope

    @total_products = base_scope.count
    @products = base_scope.includes(:category, :options, images_attachments: :blob, documentations_attachments: :blob)
                          .order(updated_at: :desc)

    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

    query = params[:query].to_s.strip
    @products = @products.where("products.name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%") if query.present?
    @products, @pagination = paginate_admin_v2(@products)
  end

  def product_params
    params.require(:product).permit(:name, :category_id, :description, :infos, :warranty)
  end

  def products_scope
    Product.where(type: nil)
  end

  def deleted_product_drawer_stream(result)
    turbo_stream.replace(
      "admin_v2_drawer",
      partial: "admin_v2/products/deleted_drawer_frame",
      locals: { result: result }
    )
  end

  def product_deleted_message(result)
    "Product##{result.product_id} deleted images=#{result.images_purged} docs=#{result.documentations_purged} options=#{result.options_destroyed} palettes=#{result.color_palettes_destroyed}"
  end

  def products_results_frame_request?
    request.headers["Turbo-Frame"] == "admin_v2_products_results"
  end

  def products_index_stream
    return products_results_stream if products_results_frame_request?

    [
      store_nav_stream(:products),
      turbo_stream.replace(
        "admin_v2_main",
        partial: "admin_v2/products/index_frame",
        locals: { products: @products, total_products: @total_products, pagination: @pagination }
      )
    ]
  end

  def products_results_stream
    turbo_stream.replace(
      "admin_v2_products_results",
      partial: "admin_v2/products/results_frame",
      locals: { products: @products, pagination: @pagination }
    )
  end
end
