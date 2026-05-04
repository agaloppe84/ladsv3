# frozen_string_literal: true

class AdminV2::Ui::PaginationComponent < ViewComponent::Base
  def initialize(pagination:, path:, params: {}, frame:)
    @pagination = pagination
    @path = path
    @params = params.to_h.symbolize_keys
    @frame = frame
  end

  private

  attr_reader :pagination, :path, :params, :frame

  def summary
    if pagination.total_count.zero?
      "0 resultat"
    else
      "#{pagination.first_item}-#{pagination.last_item} / #{pagination.total_count}"
    end
  end

  def page_items
    return (1..pagination.total_pages).to_a if pagination.total_pages <= 7

    pages = [1]
    pages << :gap if window_start > 2
    pages.concat((window_start..window_end).to_a)
    pages << :gap if window_end < pagination.total_pages - 1
    pages << pagination.total_pages
    pages.uniq
  end

  def window_start
    @window_start ||= [pagination.page - 2, 2].max
  end

  def window_end
    @window_end ||= [window_start + 4, pagination.total_pages - 1].min
  end

  def page_path(page)
    query = params.merge(page: page).compact_blank
    query.any? ? "#{path}?#{query.to_query}" : path
  end

  def link_classes(active: false, disabled: false)
    base = "admin-v2-focus inline-flex h-8 min-w-8 items-center justify-center rounded-lg border px-2 text-[10px] font-semibold transition"
    return "#{base} pointer-events-none border-white/[0.045] bg-white/[0.02] text-[var(--g-faint)]" if disabled
    return "#{base} border-[var(--g-accent-border)] bg-[var(--g-accent-soft)] text-[var(--g-accent)]" if active

    "#{base} border-white/[0.075] bg-white/[0.035] text-[var(--g-muted)] hover:border-[var(--g-accent-border)] hover:bg-[var(--g-accent-soft)] hover:text-[var(--g-accent)]"
  end
end
