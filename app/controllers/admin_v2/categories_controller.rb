class AdminV2::CategoriesController < AdminV2::BaseController
  def index
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

    respond_to do |format|
      format.html do
        if categories_results_frame_request?
          render partial: "admin_v2/categories/results_frame", locals: { categories: @categories }, layout: false
        else
          render
        end
      end
      format.turbo_stream { render turbo_stream: categories_index_stream }
    end
  end

  def show
    @category = Category.find(params[:id])
  end

  def new
    @category = Category.new(color: "green")
  end

  def create
    @category = Category.new(category_params)
    @category.errors.add(:name, "doit être renseigné") if @category.name.blank?

    if @category.errors.empty? && @category.save
      respond_to do |format|
        format.turbo_stream do
          categories = categories_scope.order(Arel.sql("LOWER(categories.name) ASC"))

          render turbo_stream: [
            turbo_stream.replace(
              "admin_v2_main",
              partial: "admin_v2/categories/index_frame",
              locals: { categories: categories, total_categories: Category.count }
            ),
            turbo_stream.replace(
              "admin_v2_drawer",
              partial: "admin_v2/categories/drawer_frame",
              locals: { category: @category }
            ),
            store_nav_stream(:categories),
            turbo_stream_flash(:success, "Category##{@category.id} created")
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

  private

  def category_params
    params.require(:category).permit(:name, :description, :color)
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
        locals: { categories: @categories, total_categories: @total_categories }
      )
    ]
  end

  def categories_results_stream
    turbo_stream.replace(
      "admin_v2_categories_results",
      partial: "admin_v2/categories/results_frame",
      locals: { categories: @categories }
    )
  end

  def categories_scope
    Category
      .left_joins(:products)
      .select("categories.*, COUNT(products.id) FILTER (WHERE products.type IS NULL) AS admin_v2_products_count")
      .group("categories.id")
  end
end
