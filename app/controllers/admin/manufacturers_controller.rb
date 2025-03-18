class Admin::ManufacturersController < AdminController

  def index
    @manufacturers = Manufacturer.all
  end

  def show
    @manufacturer = Manufacturer.find(params[:id])
  end

  def edit
    @manufacturer = Manufacturer.find(params[:id])
    @logos = Dir.glob(Rails.root.join('app', 'assets', 'images', 'logos', '*.svg')).map do |path|
      File.basename(path)
    end
  end

  def new
    @manufacturer = Manufacturer.new
    @logos = Dir.glob(Rails.root.join('app', 'assets', 'images', 'logos', '*.svg')).map do |path|
      File.basename(path)
    end
  end

  def create
    @manufacturer = Manufacturer.new(manufacturer_params)
    if @manufacturer.save
      redirect_to admin_manufacturers_path, notice: "Fabricant ajouté"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @manufacturer = Manufacturer.find(params[:id])
    if @manufacturer.update(manufacturer_params)
      redirect_to admin_manufacturers_path, notice: "Fabricant modifié"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def manufacturer_params
    params.require(:manufacturer).permit(:name, :logo)
  end
end