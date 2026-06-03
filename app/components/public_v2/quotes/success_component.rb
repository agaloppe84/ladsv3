# frozen_string_literal: true

class PublicV2::Quotes::SuccessComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(debug: false)
    @debug = debug
  end

  private

  def component_classes
    component_class_names("pv2-quote-success", debug_class)
  end
end
