# frozen_string_literal: true

module AdminV2
  class Pagination
    DEFAULT_PER_PAGE = 24

    attr_reader :scope, :page, :per_page, :total_count

    def initialize(scope:, page:, per_page: DEFAULT_PER_PAGE, total_count: nil)
      @scope = scope
      @per_page = normalize_per_page(per_page)
      @total_count = total_count || count_scope(scope)
      @page = normalize_page(page)
    end

    def records
      @records ||= scope.limit(per_page).offset(offset)
    end

    def total_pages
      @total_pages ||= [(@total_count.to_f / per_page).ceil, 1].max
    end

    def offset
      (page - 1) * per_page
    end

    def previous_page
      page > 1 ? page - 1 : nil
    end

    def next_page
      page < total_pages ? page + 1 : nil
    end

    def first_item
      return 0 if total_count.zero?

      offset + 1
    end

    def last_item
      return 0 if total_count.zero?

      [offset + per_page, total_count].min
    end

    private

    def normalize_per_page(value)
      value.to_i.clamp(1, 100)
    end

    def normalize_page(value)
      requested_page = value.to_i
      requested_page = 1 if requested_page < 1

      [requested_page, total_pages].min
    end

    def count_scope(scope)
      count = scope.except(:select, :limit, :offset, :order).count
      count.respond_to?(:size) && !count.is_a?(Numeric) ? count.size : count.to_i
    end
  end
end
