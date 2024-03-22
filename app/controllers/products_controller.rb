class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    add_breadcrumb("Home", root_path)
    add_breadcrumb("Produits", categories_path)
    add_breadcrumb(@product.category.name, @product.category)
    add_breadcrumb(@product.name)
  end
end