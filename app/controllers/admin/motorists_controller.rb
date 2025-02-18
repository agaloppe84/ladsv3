class Admin::MotoristsController < AdminController

  def index
    @motorists = Motorist.all
  end

  def show
    @motorist = Motorist.find(params[:id])
  end

  def edit
    @motorist = Motorist.find(params[:id])
  end

  def new
    @motorist = Motorist.new
  end

  def create
  end

  def update
  end

  private

  def motorist_params
    params.require(:motorist).permit(:name, :logo)
  end
end