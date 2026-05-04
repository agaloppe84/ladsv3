class AdminV2::QuoteProcessingController < AdminV2::BaseController
  before_action :set_quote

  def update
    if @quote.update(quote_params)
      render turbo_stream: [
        quote_row_stream,
        drawer_summary_stream,
        *admin_v2_feedback_streams(:success, processing_message, event_type: :processed, resource: @quote, status_code: 200)
      ]
    else
      render turbo_stream: [
        drawer_summary_stream,
        *admin_v2_feedback_streams(:warning, @quote.errors.full_messages.to_sentence.presence || "Quote processing invalid", event_type: :error, resource: @quote, status_code: 422)
      ], status: :unprocessable_entity
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:quote_id])
    track_admin_v2_context(@quote)
  end

  def quote_params
    params.require(:quote).permit(:processed)
  end

  def quote_row_stream
    turbo_stream.replace(
      "admin_v2_quote_#{@quote.id}",
      partial: "admin_v2/quotes/row",
      locals: { quote: @quote }
    )
  end

  def drawer_summary_stream
    turbo_stream.replace(
      "admin_v2_quote_drawer_summary",
      partial: "admin_v2/quotes/drawer_summary",
      locals: { quote: @quote }
    )
  end

  def processing_message
    status = @quote.processed? ? "processed" : "reopened"
    "Quote##{@quote.id} #{status}"
  end
end
