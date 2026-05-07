# frozen_string_literal: true

class PublicV2::Ui::MediaFrameComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(image: nil, fallback: "placeholder.jpg", alt: "", ratio: :wide, loading: "lazy", classes: nil, debug: false)
    @image = image
    @fallback = fallback
    @alt = alt
    @ratio = ratio
    @loading = loading
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :image, :fallback, :alt, :ratio, :loading, :classes

  def component_classes
    component_class_names(
      "pv2-ui-media",
      "pv2-ui-media--#{ratio}",
      "w-full min-w-0 overflow-hidden",
      debug_class,
      classes
    )
  end

  def cloudinary_image?
    image.present? && image.respond_to?(:key)
  end

  def asset_image
    image.presence || fallback
  end

  def image_options
    {
      alt: alt,
      class: "pv2-cover-image",
      loading: loading,
      decoding: "async",
      onerror: "this.onerror=null;this.src='#{helpers.asset_path(fallback)}'"
    }
  end
end
