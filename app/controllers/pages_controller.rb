class PagesController < ApplicationController
  def home
    @event = Event.where(':date BETWEEN start_date AND end_date', date: DateTime.now).last
    @photos = Product.all.first.images
    @carousel_products = Product.all.first(6)
    @carousel_products = []
    @categories = Category.includes(products: [images_attachments: :blob]).all
    add_breadcrumb("Accueil", root_path)
  end

  def destock
    @products = DestockProduct.all
  end

  def contact

  end

  def services
  end
end
