class Admin::QuotesController < AdminController

  def index
    @quotes = Quote.all.order(updated_at: :desc)
  end

  def show
    @quote = Quote.find(params[:id])
  end

end