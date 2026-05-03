# frozen_string_literal: true

class AdminV2::Ui::ActionStateComponent < ViewComponent::Base
  def initialize(default_label: "ready")
    @default_label = default_label
  end

  private

  attr_reader :default_label
end
