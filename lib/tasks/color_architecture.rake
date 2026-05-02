namespace :color_architecture do
  desc "Backfill new color architecture from legacy products_rals links"
  task backfill_from_legacy_rals: :environment do
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "false"))
    stop_on_error = ActiveModel::Type::Boolean.new.cast(ENV.fetch("STOP_ON_ERROR", "false"))
    part_code = ENV.fetch("PART_CODE", "main").to_s.strip
    part_label = ENV.fetch("PART_LABEL", "Coloris").to_s.strip
    limit = ENV["LIMIT"].to_i
    product_ids = ENV.fetch("PRODUCT_IDS", "")
                     .split(",")
                     .map(&:strip)
                     .reject(&:blank?)
                     .map(&:to_i)

    if part_code.blank? || part_label.blank?
      raise ArgumentError, "PART_CODE and PART_LABEL must be present"
    end

    scope = Product.order(:id)
    scope = scope.where(id: product_ids) if product_ids.any?
    scope = scope.limit(limit) if limit.positive?

    stats = {
      scanned: 0,
      products_without_rals: 0,
      parts_created: 0,
      palettes_created: 0,
      items_created: 0,
      items_already_present: 0,
      errors: 0
    }

    puts "[color_architecture] start dry_run=#{dry_run} stop_on_error=#{stop_on_error}"
    puts "[color_architecture] filters PRODUCT_IDS=#{product_ids.inspect} LIMIT=#{limit.positive? ? limit : "none"}"

    scope.find_each do |product|
      stats[:scanned] += 1

      begin
        ral_ids = product.ral_ids
        if ral_ids.empty?
          stats[:products_without_rals] += 1
          next
        end

        result = backfill_product!(
          product: product,
          ral_ids: ral_ids,
          part_code: part_code,
          part_label: part_label,
          dry_run: dry_run
        )

        stats[:parts_created] += result[:parts_created]
        stats[:palettes_created] += result[:palettes_created]
        stats[:items_created] += result[:items_created]
        stats[:items_already_present] += result[:items_already_present]
      rescue StandardError => e
        stats[:errors] += 1
        warn "[color_architecture] product_id=#{product.id} ERROR #{e.class}: #{e.message}"
        raise if stop_on_error
      end
    end

    puts "[color_architecture] done"
    stats.each do |key, value|
      puts "[color_architecture] #{key}=#{value}"
    end
  end

  def backfill_product!(product:, ral_ids:, part_code:, part_label:, dry_run:)
    result = {
      parts_created: 0,
      palettes_created: 0,
      items_created: 0,
      items_already_present: 0
    }

    part = product.product_color_parts.where("LOWER(code) = ?", part_code.downcase).first

    if part.nil?
      if dry_run
        result[:parts_created] += 1
        result[:palettes_created] += 1
        return simulate_items(result: result, ral_ids: ral_ids)
      end

      ProductColorPart.transaction do
        palette = ColorPalette.create!(name: "Legacy colors ##{product.id}")
        part = product.product_color_parts.create!(
          code: part_code,
          label: part_label,
          color_palette: palette
        )
        result[:parts_created] += 1
        result[:palettes_created] += 1
      end
    elsif part.color_palette.nil?
      if dry_run
        result[:palettes_created] += 1
        return simulate_items(result: result, ral_ids: ral_ids)
      end

      palette = ColorPalette.create!(name: "Legacy colors ##{product.id}")
      part.update!(color_palette: palette)
      result[:palettes_created] += 1
    end

    if dry_run
      existing = part.color_palette.color_palette_items.where(finish_id: nil).pluck(:ral_id)
      already_present = ral_ids & existing
      missing = ral_ids - existing
      result[:items_created] += missing.size
      result[:items_already_present] += already_present.size
      return result
    end

    existing = part.color_palette.color_palette_items.where(finish_id: nil).pluck(:ral_id)
    already_present = ral_ids & existing
    missing = ral_ids - existing

    missing.each do |ral_id|
      part.color_palette.color_palette_items.create!(
        ral_id: ral_id,
        finish_id: nil,
        paid_option: false
      )
      result[:items_created] += 1
    end

    result[:items_already_present] += already_present.size
    result
  end

  def simulate_items(result:, ral_ids:)
    result[:items_created] += ral_ids.size
    result
  end
end
