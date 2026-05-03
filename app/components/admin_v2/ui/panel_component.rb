# frozen_string_literal: true

class AdminV2::Ui::PanelComponent < ViewComponent::Base
  renders_one :actions

  def initialize(title: nil, subtitle: nil, id: nil, data: {})
    @title = title
    @subtitle = subtitle
    @id = id
    @data = data
  end

  private

  attr_reader :title, :subtitle, :id, :data
end
