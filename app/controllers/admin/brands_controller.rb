class Admin::BrandsController < AdminController

  def index
    @brands = Brand.all
  end

  def show
    @brand = Brand.find(params[:id])
  end

  def edit
    @brand = Brand.find(params[:id])
    @logos = Dir.glob(Rails.root.join('app', 'assets', 'images', 'logos', '*.svg')).map do |path|
      File.basename(path)
    end
  end

  def new
    @brand = Brand.new
    @logos = Dir.glob(Rails.root.join('app', 'assets', 'images', 'logos', '*.svg')).map do |path|
      File.basename(path)
    end
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      redirect_to admin_brands_path, notice: "Marque ajoutée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @brand = Brand.find(params[:id])
    if @brand.update(brand_params)
      redirect_to admin_brands_path, notice: "Marque modifiée"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def brand_params
    params.require(:brand).permit(:name, :logo)
  end
end