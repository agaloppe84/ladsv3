class AdminV2::UploadPolicy
  Validation = Struct.new(:valid, :message, keyword_init: true) do
    def valid?
      valid
    end
  end

  CONFIG = {
    image: {
      label: "Image",
      max_bytes: 12.megabytes,
      content_types: %w[image/jpeg image/png image/webp],
      formats: "JPG, PNG ou WEBP"
    },
    category_hero_image: {
      label: "Image hero catégorie",
      max_bytes: 6.megabytes,
      content_types: %w[image/webp],
      formats: "WEBP"
    },
    product_front_image: {
      label: "Image front produit",
      max_bytes: 6.megabytes,
      content_types: %w[image/webp],
      formats: "WEBP"
    },
    documentation: {
      label: "Documentation",
      max_bytes: 25.megabytes,
      content_types: %w[application/pdf image/jpeg image/png image/webp],
      formats: "PDF, JPG, PNG ou WEBP"
    }
  }.freeze

  class << self
    def validate_blob(blob, field)
      config = config_for(field)

      return invalid("#{config[:label]} introuvable. Relance l'upload.") if blob.blank?

      if blob.byte_size.to_i > config[:max_bytes]
        return invalid("#{config[:label]} trop lourd : #{human_size(blob.byte_size)}. Limite : #{human_size(config[:max_bytes])}.")
      end

      unless config[:content_types].include?(blob.content_type)
        return invalid("#{config[:label]} non supporté : #{blob.content_type.presence || 'type inconnu'}. Formats autorisés : #{config[:formats]}.")
      end

      Validation.new(valid: true)
    end

    def label(field)
      config_for(field)[:label]
    end

    def max_size_mb(field)
      (config_for(field)[:max_bytes].to_f / 1.megabyte).round
    end

    def accept(field)
      config_for(field)[:content_types].join(",")
    end

    private

    def config_for(field)
      CONFIG.fetch(field.to_sym)
    end

    def invalid(message)
      Validation.new(valid: false, message: message)
    end

    def human_size(bytes)
      "#{(bytes.to_f / 1.megabyte).round(1)} MB"
    end
  end
end
