class PagesController < ApplicationController
  def home
    @event = Event.where(':date BETWEEN start_date AND end_date', date: DateTime.now).last
    @photos = Product.all.first.images
    @carousel_products = Product.all.first(6)
    @carousel_products = []
    add_breadcrumb("Home", root_path)
  end

  def destock
    @products = DestockProduct.all
  end

  def contact

  end

  def services
  end
end