class Admin::ProductsController < AdminController

  def index
    @products = Product.all
  end

  def show

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
    params.require(:product).permit(:name, :description, service_attributes: [:id, :warranty, :custom_dimensions, :made_in_france], options_attributes: [:id, :order, :content, :_destroy], motorist_ids: [], ral_ids: [], images: [])
  end
end