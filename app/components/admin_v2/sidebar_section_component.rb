# frozen_string_literal: true

class AdminV2::SidebarSectionComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end

  private

  attr_reader :title
end
