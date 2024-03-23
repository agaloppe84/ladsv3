# frozen_string_literal: true

class PhotoslistComponent < ViewComponent::Base

  def initialize(photos)
    @photos = photos
  end

  def render?
    @photos.present?
  end

end
