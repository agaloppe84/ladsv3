# frozen_string_literal: true

class PublicV2::Categories::ListSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(sections:)
    @sections = sections
  end

  private

  attr_reader :sections

  def component_classes
    [
      "pv2-public-index__categories",
      "grid w-full min-w-0 gap-5",
      debug_class
    ].compact.join(" ")
  end
end
