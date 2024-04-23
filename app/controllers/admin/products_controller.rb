class Admin::ProductsController < AdminController

  def index
    @products = Product.all
  end

  def show

  end

  def new
    @product = Product.new
  end

  def create

  end

  def update

  end

  private

  def product_params
    params.require(:product).permit(:name, :description)
  end
end