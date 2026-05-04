class CategoriesController < ApplicationController
  def index
    @categories = Category.published.order(:name)
    @event = Event.where(':date BETWEEN start_date AND end_date', date: DateTime.now).last
    add_breadcrumb("Accueil", root_path)
    add_breadcrumb("Produits", categories_path)
  end

  def show
    @categories = Category.published.order(:name)
    @category = Category.published.find(params[:id])
    @products = @category.products.where(type: nil).order(:name)
    add_breadcrumb("Accueil", root_path)
    add_breadcrumb("Produits", categories_path)
    add_breadcrumb(@category.name, nil, @category.products.count)
  end
end
