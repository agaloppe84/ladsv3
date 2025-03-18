class Admin::ProductsController < AdminController

  def index
    @categories = Category.all
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      # Mettre la catégorie sélectionnée en premier, puis les autres
      @categories = [@category] + @categories.reject { |cat| cat.id == @category.id }
      @products = Product.where(category: @category, type: nil).order(updated_at: :desc)
    else
      @products = Product.where(type: nil).order(updated_at: :desc)
    end
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def edit
    @product = Product.find(params[:id])
    if !@product.service
      puts "SERVICE NON PRESENT !!!!!!!!!!!!!!"
      @service = @product.build_service
    end
  end

  def create

  end

  def update
    @product = Product.find(params[:id])

    if @product.update(product_params)
      # Envoi d'un turbo_stream pour rester sur la même page et afficher la notification
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('product-notification', partial: 'admin/products/notification', locals: { notice: 'Produit mis à jour !!' })
        end
        format.html { redirect_to admin_products_path, notice: "Produit mis à jour !!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :infos, :category_id, :brand_id, :warranty, service_attributes: [:id, :warranty, :custom_dimensions, :made_in_france, :anti_fire, :anti_uv, :rge, :wind_resistance, :free_quote], options_attributes: [:id, :order, :content, :_destroy], manufacturer_ids: [],  motorist_ids: [], ral_ids: [], documentations: [], images: [])
  end
end