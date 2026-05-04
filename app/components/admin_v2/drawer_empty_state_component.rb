# frozen_string_literal: true

class AdminV2::DrawerEmptyStateComponent < ViewComponent::Base
  def initialize(title: "Context drawer", message: nil)
    @title = title
    @message = message
  end

  private

  attr_reader :title, :message
end
