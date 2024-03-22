class PagesController < ApplicationController
  def home
    add_breadcrumb("Home", root_path)
  end

  def services
  end
end