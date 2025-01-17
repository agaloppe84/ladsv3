# frozen_string_literal: true

class Admin::ListComponent < ViewComponent::Base

  def initialize(items)
    @items = items
  end

  def render?
    @items.present?
  end

end
