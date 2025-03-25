class Admin::QuotesController < AdminController
  before_action :set_quote, only: [:update]
  def index
    @quotes = Quote.all.order(updated_at: :desc)
  end

  def show
    @quote = Quote.find(params[:id])
  end

  def update
    if @quote.update(quote_params)
      respond_to do |format|
        format.html { redirect_to admin_quotes_path, notice: "Le devis a été mis à jour." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("quote_#{@quote.id}",
                                                     partial: "admin/quotes/quote_row",
                                                     locals: { quote: @quote })
        end
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @quote = Quote.find(params[:id])
    @quote.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("quote_#{@quote.id}") }
      format.html { redirect_to admin_quotes_path, notice: "Devis supprimé." }
    end
  end


  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:processed)
  end

end