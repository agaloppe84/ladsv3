# frozen_string_literal: true

class AdminV2::Quotes::StatusBadgeComponent < ViewComponent::Base
  def initialize(quote:)
    @quote = quote
  end

  private

  attr_reader :quote

  def label
    quote.processed? ? "traité" : "non traité"
  end

  def classes
    if quote.processed?
      "border-emerald-300/20 bg-emerald-300/10 text-[var(--g-green)]"
    else
      "border-amber-300/20 bg-amber-300/10 text-[var(--g-amber)]"
    end
  end
end
