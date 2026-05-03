# frozen_string_literal: true

class AdminV2::Events::StatusBadgeComponent < ViewComponent::Base
  def initialize(event:)
    @event = event
  end

  private

  attr_reader :event

  def label
    {
      active: "Actif",
      upcoming: "À venir",
      expired: "Expiré",
      incomplete: "Incomplet"
    }.fetch(status)
  end

  def variant
    {
      active: :success,
      upcoming: :accent,
      expired: :neutral,
      incomplete: :warning
    }.fetch(status)
  end

  def status
    return :incomplete if event.start_date.blank? || event.end_date.blank?
    return :active if event.start_date <= Time.current && event.end_date >= Time.current
    return :upcoming if event.start_date > Time.current

    :expired
  end
end
