# frozen_string_literal: true

class Product::GalleryComponent < ViewComponent::Base
  def initialize(photos:)
    @photos = photos
  end

  def render?
    @photos.attached?
  end
end
