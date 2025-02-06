class Admin::BrandsController < AdminController

  def index
    @brands = Brand.all
  end

  def show
    @brand = Brand.find(params[:id])
  end

  def edit
    @brand = Brand.find(params[:id])
  end

  def new
    @brand = Brand.new
  end

  def create

  end

  def update

  end

  private

  def brand_params
    params.require(:brand).permit(:name, :logo)
  end
end