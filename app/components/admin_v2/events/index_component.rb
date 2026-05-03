# frozen_string_literal: true

class AdminV2::Events::IndexComponent < ViewComponent::Base
  def initialize(events:)
    @events = events
  end

  private

  attr_reader :events
end
