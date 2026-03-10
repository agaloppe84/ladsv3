require "set"

namespace :products do
  desc "Backfill missing slugs for existing products"
  task backfill_slugs: :environment do
    products = Product.order(:id)
    existing_slugs = Set.new(Product.where.not(slug: [nil, ""]).pluck(:slug))

    updated_count = 0
    skipped_count = 0

    products.find_each do |product|
      if product.slug.present?
        skipped_count += 1
        next
      end

      base_slug = product.name.to_s.parameterize
      base_slug = "product-#{product.id}" if base_slug.blank?

      slug = base_slug
      suffix = 2

      while existing_slugs.include?(slug)
        slug = "#{base_slug}-#{suffix}"
        suffix += 1
      end

      product.update_column(:slug, slug)
      existing_slugs << slug
      updated_count += 1
    end

    puts "Products scanned: #{products.count}"
    puts "Slugs created: #{updated_count}"
    puts "Skipped (already had slug): #{skipped_count}"
  end
end
