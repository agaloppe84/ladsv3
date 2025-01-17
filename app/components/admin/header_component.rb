# frozen_string_literal: true

class Admin::HeaderComponent < ViewComponent::Base

  def initialize(title:, path: nil)
    @title = title
    @path = path
  end

end
