# frozen_string_literal: true

class AdminV2::Events::RowComponent < ViewComponent::Base
  def initialize(event:)
    @event = event
  end

  private

  attr_reader :event

  def title
    event.title.presence || "Event sans titre"
  end

  def content_preview
    event.content.to_s.squish.presence || "Aucun contenu public."
  end

  def formatted_datetime(datetime)
    return "non défini" unless datetime

    helpers.l(datetime, format: :short)
  end
end
