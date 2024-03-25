# frozen_string_literal: true

class ServiceslistComponent < ViewComponent::Base

  def initialize(service)
    @service = service
  end

  def render?
    @service.present?
  end

end
