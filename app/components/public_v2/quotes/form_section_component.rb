# frozen_string_literal: true

class PublicV2::Quotes::FormSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(quote_page:, url: nil, debug: false)
    @quote_page = quote_page
    @url = url
    @debug = debug
  end

  private

  attr_reader :quote_page, :url

  def form_url
    url.presence || public_v2_quotes_path
  end

  def component_classes
    component_class_names(
      "pv2-quote-layout",
      "grid w-full min-w-0 grid-cols-1 items-start gap-4 min-[1121px]:grid-cols-[minmax(0,1fr)_380px]",
      debug_class
    )
  end
end
