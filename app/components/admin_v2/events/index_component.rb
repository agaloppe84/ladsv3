# frozen_string_literal: true

class AdminV2::Events::IndexComponent < ViewComponent::Base
  def initialize(events:, pagination: nil)
    @events = events
    @pagination = pagination
  end

  private

  attr_reader :events, :pagination
end
