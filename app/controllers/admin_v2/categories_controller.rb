class AdminV2::CategoriesController < AdminV2::BaseController
  def index
    load_categories_index

    respond_to do |format|
      format.html do
        if categories_results_frame_request?
          render partial: "admin_v2/categories/results_frame", locals: { categories: @categories, pagination: @pagination }, layout: false
        else
          render
        end
      end
      format.turbo_stream { render turbo_stream: categories_index_stream }
    end
  end

  def show
    @category = Category.find(params[:id])
    track_admin_v2_context(@category)
  end

  def new
    @category = Category.new(color: "green", active: false)
  end

  def create
    @category = Category.new(category_params)
    @category.active = false
    @category.errors.add(:name, "doit être renseigné") if @category.name.blank?

    if @category.errors.empty? && @category.save
      respond_to do |format|
        format.turbo_stream do
          categories, pagination = paginate_admin_v2(categories_scope.order(Arel.sql("LOWER(categories.name) ASC")))

          render turbo_stream: [
            turbo_stream.replace(
              "admin_v2_main",
              partial: "admin_v2/categories/index_frame",
              locals: { categories: categories, total_categories: Category.count, pagination: pagination }
            ),
            turbo_stream.replace(
              "admin_v2_drawer",
              partial: "admin_v2/categories/drawer_frame",
              locals: { category: @category }
            ),
            store_nav_stream(:categories),
            *admin_v2_feedback_streams(:success, "Category##{@category.id} created", event_type: :create, resource: @category, status_code: 200)
          ]
        end
        format.html { redirect_to admin_v2_categories_path, notice: "Catégorie créée" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, formats: :html, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    product_count = products_count(@category)

    if product_count.positive?
      render_category_delete_blocked(product_count)
      return
    end

    result = {
      id: @category.id,
      name: @category.name.presence || "Catégorie sans nom"
    }

    @category.destroy!
    load_categories_index

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "admin_v2_main",
            partial: "admin_v2/categories/index_frame",
            locals: { categories: @categories, total_categories: @total_categories, pagination: @pagination }
          ),
          deleted_category_drawer_stream(result),
          store_nav_stream(:categories),
          *admin_v2_feedback_streams(:success, "Category##{result[:id]} deleted", event_type: :delete, metadata: { source: "cleanup", resource_type: "Category", resource_id: result[:id] }, status_code: 200)
        ]
      end
      format.html { redirect_to admin_v2_categories_path, notice: "Catégorie supprimée" }
    end
  rescue ActiveRecord::ActiveRecordError => e
    record = e.respond_to?(:record) ? e.record : nil

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: admin_v2_feedback_streams(
          :error,
          record&.errors&.full_messages&.to_sentence.presence || "Category delete failed",
          event_type: :error,
          resource: @category,
          metadata: { source: "cleanup" },
          status_code: 422
        ), status: :unprocessable_entity
      end
      format.html { redirect_to admin_v2_categories_path, alert: "Suppression impossible" }
    end
  end

  private

  def load_categories_index
    base_scope = categories_scope

    @total_categories = Category.count
    @categories = base_scope.order(Arel.sql("LOWER(categories.name) ASC"))

    query = params[:query].to_s.strip
    if query.present?
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(query)
      @categories = @categories.where(
        "categories.name ILIKE :query OR categories.description ILIKE :query OR categories.color ILIKE :query",
        query: "%#{sanitized_query}%"
      )
    end
    @categories, @pagination = paginate_admin_v2(@categories)
  end

  def category_params
    params.require(:category).permit(:name, :description, :color)
  end

  def render_category_delete_blocked(product_count)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: admin_v2_feedback_streams(
          :warning,
          "Category##{@category.id} delete blocked products=#{product_count}",
          event_type: :error,
          resource: @category,
          metadata: { source: "cleanup" },
          status_code: 422
        ), status: :unprocessable_entity
      end
      format.html { redirect_to admin_v2_categories_path, alert: "Supprime ou déplace les produits avant de supprimer cette catégorie." }
    end
  end

  def products_count(category)
    category.products.count
  end

  def deleted_category_drawer_stream(result)
    turbo_stream.replace(
      "admin_v2_drawer",
      partial: "admin_v2/categories/deleted_drawer_frame",
      locals: { result: result }
    )
  end

  def categories_results_frame_request?
    request.headers["Turbo-Frame"] == "admin_v2_categories_results"
  end

  def categories_index_stream
    return categories_results_stream if categories_results_frame_request?

    [
      store_nav_stream(:categories),
      turbo_stream.replace(
        "admin_v2_main",
        partial: "admin_v2/categories/index_frame",
        locals: { categories: @categories, total_categories: @total_categories, pagination: @pagination }
      )
    ]
  end

  def categories_results_stream
    turbo_stream.replace(
      "admin_v2_categories_results",
      partial: "admin_v2/categories/results_frame",
      locals: { categories: @categories, pagination: @pagination }
    )
  end

  def categories_scope
    Category.select(
      <<~SQL.squish
        categories.*,
        (
          SELECT COUNT(*)
          FROM products
          WHERE products.category_id = categories.id
            AND products.type IS NULL
        ) AS admin_v2_products_count
      SQL
    )
  end
end
