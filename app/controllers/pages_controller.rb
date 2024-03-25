class PagesController < ApplicationController
  def home
    @event = Event.where(':date BETWEEN start_date AND end_date', date: DateTime.now).last
    @photo = Product.find(1).images.first
    add_breadcrumb("Home", root_path)
  end

  def services
  end
end