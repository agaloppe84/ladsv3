class ApplicationController < ActionController::Base
  helper_method :breadcrumbs

  def breadcrumbs
    @breadcrumbs ||= []
  end

  def add_breadcrumb(name, path = nil, count = nil)
    breadcrumbs << Breadcrumb.new(name, path, count)
  end

end
