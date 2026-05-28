# frozen_string_literal: true

class PublicV2::Ui::ShowcaseCarouselSlideComponent < ViewComponent::Base
  include PublicV2::Debuggable

  ACTIONS = %i[none link modal button].freeze
  MEDIA_RATIOS = %i[wide product category square].freeze

  def initialize(kicker: nil, title: nil, text: nil, meta: nil, image: nil, fallback: "placeholder.jpg", alt: "", path: nil, modal_image: nil, modal_alt: nil, modal_caption: nil, action: nil, image_ratio: :wide, loading: "lazy", classes: nil, data: {}, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @meta = meta
    @image = image
    @fallback = fallback
    @alt = alt
    @path = path
    @modal_image = modal_image
    @modal_alt = modal_alt
    @modal_caption = modal_caption
    @action = normalize_action(action)
    @image_ratio = normalize_option(image_ratio, MEDIA_RATIOS, :wide)
    @loading = loading
    @classes = classes
    @data = data
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :meta, :image, :fallback, :alt, :path, :modal_image, :modal_alt, :modal_caption, :action, :image_ratio, :loading, :classes, :data

  def normalize_action(value)
    return :modal if value.blank? && modal_source.present?
    return :link if value.blank? && path.present?

    normalize_option(value, ACTIONS, :none)
  end

  def modal_source
    modal_image.presence
  end

  def clickable?
    action != :none
  end

  def link?
    action == :link && path.present?
  end

  def modal?
    action == :modal && modal_source.present?
  end

  def button?
    action == :button
  end

  def component_classes
    component_class_names(
      "pv2-ui-showcase-slide",
      "pv2-ui-showcase-slide--#{image_ratio}",
      "grid min-w-0 overflow-hidden",
      ("pv2-ui-showcase-slide--interactive" if clickable?),
      debug_class,
      classes
    )
  end

  def component_data
    base_data = with_debug_data(data)
    return base_data unless modal?

    base_data.merge(
      action: [base_data[:action], "showcase-carousel#openModal"].compact.join(" "),
      showcase_carousel_src_param: modal_source_url,
      showcase_carousel_alt_param: modal_alt.presence || alt.presence || title,
      showcase_carousel_caption_param: modal_caption.presence || title
    )
  end

  def image_source
    image.presence || fallback
  end

  def cloudinary_image?
    image_source.respond_to?(:key)
  end

  def modal_source_url
    if modal_source.respond_to?(:key)
      helpers.cl_image_path(modal_source.key)
    else
      helpers.image_path(modal_source)
    end
  end

  def image_options
    {
      alt: alt.presence || title.to_s,
      class: "pv2-ui-showcase-slide__image",
      loading: loading,
      decoding: "async",
      onerror: "this.onerror=null;this.src='#{helpers.asset_path(fallback)}'"
    }
  end
end
