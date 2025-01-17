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
    puts "!!!!!!!!!!!!!!! INTO UPDATE CONTROLLER !!!!!!!!!!!!!"
    @product = Product.find(params[:id])

    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Produit mis à jour !!"
    else
      puts "!!!!!!!!!!!!! ERROR !!!!!!!!!!!!!!"
      puts @product.errors.inspect
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, service_attributes: [:id, :warranty, :custom_dimensions, :made_in_france], options_attributes: [:id, :order, :content, :_destroy], images: [])
  end
end