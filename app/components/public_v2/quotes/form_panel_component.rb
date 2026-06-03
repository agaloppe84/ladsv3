# frozen_string_literal: true

class PublicV2::Quotes::FormPanelComponent < ViewComponent::Base
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
    component_class_names("pv2-quote-form-panel", debug_class)
  end
end
