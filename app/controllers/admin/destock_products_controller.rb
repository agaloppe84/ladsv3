class Admin::DestockProductsController < AdminController

  def index
    @categories = Category.all
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      # Mettre la catégorie sélectionnée en premier, puis les autres
      @categories = [@category] + @categories.reject { |cat| cat.id == @category.id }
      @products = DestockProduct.where(category: @category).order(updated_at: :desc)
    else
      @products = DestockProduct.all.order(updated_at: :desc)
    end
  end

  def show
    @product = DestockProduct.find(params[:id])
  end

  def new
    @product = DestockProduct.new
  end

  def edit
    @product = DestockProduct.find(params[:id])
    if !@product.service
      puts "SERVICE NON PRESENT !!!!!!!!!!!!!!"
      @service = @product.build_service
    end
  end

  def create
    @product = DestockProduct.new(product_params)

    if @product.save
      # Envoi d'un turbo_stream pour rester sur la même page et afficher la notification
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('product-notification', partial: 'admin/products/notification', locals: { notice: 'Produit enregistré !!' })
        end
        format.html { redirect_to admin_destock_products_path, notice: "Produit enregistré" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update
    @product = DestockProduct.find(params[:id])

    if @product.update(product_params)
      # Envoi d'un turbo_stream pour rester sur la même page et afficher la notification
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('product-notification', partial: 'admin/products/notification', locals: { notice: 'Produit mis à jour !!' })
        end
        format.html { redirect_to admin_destock_products_path, notice: "Produit mis à jour !!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product = DestockProduct.find(params[:id])
    @product.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("product_#{@product.id}") }
      format.html { redirect_to admin_products_path, notice: "Produit supprimé." }
    end
  end

  private

  def product_params
    params.require(:destock_product).permit(:name, :old_price, :new_price, :dimensions, :description, :infos, :category_id, :warranty, service_attributes: [:id, :warranty, :custom_dimensions, :made_in_france, :anti_fire, :anti_uv, :rge, :wind_resistance, :free_quote], options_attributes: [:id, :order, :content, :_destroy], manufacturer_ids: [], motorist_ids: [], ral_ids: [], images: [])
  end
end