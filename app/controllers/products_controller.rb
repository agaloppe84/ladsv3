class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :show_wip, :canvas_selector]
  before_action :set_breadcrumbs, only: [:show, :show_wip]
  before_action :set_canvas_selector_breadcrumbs, only: [:canvas_selector]

  def show
  end

  def show_wip
  end

  def canvas_selector
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb("Home", root_path)
    add_breadcrumb("Produits", categories_path)
    add_breadcrumb(@product.category.name, @product.category)
    add_breadcrumb(@product.name)
  end

  def set_canvas_selector_breadcrumbs
    add_breadcrumb("Home", root_path)
    add_breadcrumb("Produits", categories_path)
    add_breadcrumb(@product.category.name, @product.category)
    add_breadcrumb(@product.name, product_path(@product))
    add_breadcrumb("Sélecteur de toile")
  end
end
