class QuotesController < ApplicationController
  def new
    if params[:product_id]
      @product = Product.find(params[:product_id])
    end
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
    if @quote.save
      redirect_to root_path, notice: "Demande de devis envoyée avec succès !!"
    else
      flash.alert = "Veuillez remplir les champs obligatoires"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:product, :lastname, :email, :phone, :message, :city, :address)
  end
end