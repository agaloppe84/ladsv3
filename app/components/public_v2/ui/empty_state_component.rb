# frozen_string_literal: true

class PublicV2::Ui::EmptyStateComponent < ViewComponent::Base
  def initialize(message:, title: nil, action_label: nil, action_path: nil, classes: nil)
    @title = title
    @message = message
    @action_label = action_label
    @action_path = action_path
    @classes = classes
  end

  private

  attr_reader :title, :message, :action_label, :action_path, :classes

  def component_classes
    ["pv2-public-empty", "pv2-ui-empty", "grid w-full min-w-0 gap-2", classes].compact.join(" ")
  end
end
