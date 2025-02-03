class Admin::CategoriesController < AdminController

  def index
    @categories = Category.all
  end

  def show

  end

  def edit
    @category = Category.find(params[:id])
  end

  def new
    @category = Category.new
  end

  def create

  end

  def update

  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end
end