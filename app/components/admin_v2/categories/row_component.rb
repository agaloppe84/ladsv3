# frozen_string_literal: true

class AdminV2::Categories::RowComponent < ViewComponent::Base
  def initialize(category:)
    @category = category
  end

  private

  attr_reader :category

  def name
    category.name.presence || "Catégorie sans nom"
  end

  def description
    category.description.to_s.squish.presence || "Aucune description"
  end

  def store_products_count
    counted_value = begin
      category.read_attribute(:admin_v2_products_count)
    rescue ActiveModel::MissingAttributeError
      nil
    end

    (counted_value || category.products.where(type: nil).count).to_i
  end

  def updated_at
    helpers.l(category.updated_at, format: :short)
  end

  def index_params
    helpers.request.query_parameters.slice("query", "page")
  end
end
