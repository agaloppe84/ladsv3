# frozen_string_literal: true

class PublicV2::Ui::EmptyStateComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(message:, title: nil, action_label: nil, action_path: nil, classes: nil, debug: false)
    @title = title
    @message = message
    @action_label = action_label
    @action_path = action_path
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :title, :message, :action_label, :action_path, :classes

  def component_classes
    component_class_names("pv2-public-empty", "pv2-ui-empty", "grid w-full min-w-0 gap-2", debug_class, classes)
  end
end
