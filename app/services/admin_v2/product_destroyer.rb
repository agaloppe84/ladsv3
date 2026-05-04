# frozen_string_literal: true

module AdminV2
  class ProductDestroyer
    Result = Struct.new(
      :product_id,
      :product_name,
      :images_purged,
      :documentations_purged,
      :options_destroyed,
      :color_parts_destroyed,
      :color_palettes_destroyed,
      keyword_init: true
    )

    def initialize(product)
      @product = product
    end

    def destroy!
      product_id = product.id
      product_name = product.name
      image_attachments = product.images.attachments.includes(:blob).to_a
      documentation_attachments = product.documentations.attachments.includes(:blob).to_a
      color_palettes = product.color_palettes.distinct.to_a

      result = Result.new(
        product_id: product_id,
        product_name: product_name,
        images_purged: image_attachments.size,
        documentations_purged: documentation_attachments.size,
        options_destroyed: product.options.count,
        color_parts_destroyed: product.product_color_parts.count,
        color_palettes_destroyed: 0
      )

      purge_attachments(image_attachments + documentation_attachments)
      product.destroy!
      result.color_palettes_destroyed = destroy_orphan_color_palettes(color_palettes)
      result
    end

    private

    attr_reader :product

    def purge_attachments(attachments)
      attachments.each(&:purge)
    end

    def destroy_orphan_color_palettes(color_palettes)
      color_palettes.count do |color_palette|
        color_palette.reload
        next false if color_palette.product_color_parts.exists?

        color_palette.destroy!
        true
      rescue ActiveRecord::RecordNotFound
        false
      end
    end
  end
end
