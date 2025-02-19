class Admin::MotoristsController < AdminController

  def index
    @motorists = Motorist.all
  end

  def show
    @motorist = Motorist.find(params[:id])
  end

  def edit
    @motorist = Motorist.find(params[:id])
    @logos = Dir.glob(Rails.root.join('app', 'assets', 'images', 'logos', '*.svg')).map do |path|
      File.basename(path)
    end
  end

  def new
    @motorist = Motorist.new
    @logos = Dir.glob(Rails.root.join('app', 'assets', 'images', 'logos', '*.svg')).map do |path|
      File.basename(path)
    end
  end

  def create
    @motorist = Motorist.new(motorist_params)
    if @motorist.save
      redirect_to admin_motorists_path, notice: "Motoriste ajouté"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @motorist = Motorist.find(params[:id])
    if @motorist.update(motorist_params)
      redirect_to admin_motorists_path, notice: "Motoriste modifié"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def motorist_params
    params.require(:motorist).permit(:name, :logo)
  end
end