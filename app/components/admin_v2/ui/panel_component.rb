# frozen_string_literal: true

class AdminV2::Ui::PanelComponent < ViewComponent::Base
  def initialize(title: nil, subtitle: nil, id: nil)
    @title = title
    @subtitle = subtitle
    @id = id
  end

  private

  attr_reader :title, :subtitle, :id
end
