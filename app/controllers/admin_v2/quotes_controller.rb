class AdminV2::QuotesController < AdminV2::BaseController
  def index
    base_scope = Quote.all

    @total_quotes = base_scope.count
    @quotes = base_scope.order(created_at: :desc, updated_at: :desc)

    query = params[:query].to_s.strip
    if query.present?
      sanitized_query = ActiveRecord::Base.sanitize_sql_like(query)
      @quotes = @quotes.where(
        "quotes.lastname ILIKE :query OR quotes.email ILIKE :query OR quotes.phone ILIKE :query OR quotes.product ILIKE :query OR quotes.city ILIKE :query",
        query: "%#{sanitized_query}%"
      )
    end
    @quotes, @pagination = paginate_admin_v2(@quotes)

    respond_to do |format|
      format.html do
        if quotes_results_frame_request?
          render partial: "admin_v2/quotes/results_frame", locals: { quotes: @quotes, pagination: @pagination }, layout: false
        else
          render
        end
      end
      format.turbo_stream { render turbo_stream: quotes_index_stream }
    end
  end

  def show
    @quote = Quote.find(params[:id])
    track_admin_v2_context(@quote)
  end

  private

  def quotes_results_frame_request?
    request.headers["Turbo-Frame"] == "admin_v2_quotes_results"
  end

  def quotes_index_stream
    return quotes_results_stream if quotes_results_frame_request?

    [
      store_nav_stream(:quotes),
      turbo_stream.replace(
        "admin_v2_main",
        partial: "admin_v2/quotes/index_frame",
        locals: { quotes: @quotes, total_quotes: @total_quotes, pagination: @pagination }
      )
    ]
  end

  def quotes_results_stream
    turbo_stream.replace(
      "admin_v2_quotes_results",
      partial: "admin_v2/quotes/results_frame",
      locals: { quotes: @quotes, pagination: @pagination }
    )
  end
end
