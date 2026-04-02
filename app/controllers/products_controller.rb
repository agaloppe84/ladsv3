class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :canvas_selector]
  before_action :set_breadcrumbs, only: [:show]
  before_action :set_canvas_selector_breadcrumbs, only: [:canvas_selector]

  def show
  end

  def canvas_selector
  end

  private

  def set_product
    @product = Product.find_by!(slug: params[:slug])
  end

  def set_breadcrumbs
    add_breadcrumb("Accueil", root_path)
    add_breadcrumb("Produits", categories_path)
    add_breadcrumb(@product.category.name, @product.category)
    add_breadcrumb(@product.name)
  end

  def set_canvas_selector_breadcrumbs
    add_breadcrumb("Accueil", root_path)
    add_breadcrumb("Produits", categories_path)
    add_breadcrumb(@product.category.name, @product.category)
    add_breadcrumb(@product.name, product_path(slug: @product.slug))
    add_breadcrumb("Sélecteur de toile")
  end
end
