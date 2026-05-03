class ApplicationController < ActionController::Base
  helper_method :breadcrumbs

  def after_sign_in_path_for(resource)
    path = stored_location_for(resource) || admin_v2_root_path
    session[:admin_v2_boot_panel] = true if path.to_s.start_with?(admin_v2_root_path)
    path
  end

  def breadcrumbs
    @breadcrumbs ||= []
  end

  def add_breadcrumb(name, path = nil, count = nil)
    breadcrumbs << Breadcrumb.new(name, path, count)
  end

end
