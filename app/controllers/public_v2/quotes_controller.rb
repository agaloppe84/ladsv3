class PublicV2::QuotesController < PublicV2::BaseController
  def new
    load_quote_context
    quote = Quote.new(product: @selected_product&.name)
    @quote_page = build_quote_page(quote)
  end

  def create
    load_quote_context
    quote = Quote.new(quote_params)

    if quote.save
      redirect_to public_v2_home_path, notice: "Demande de devis envoyee avec succes."
    else
      @quote_page = build_quote_page(quote)
      flash.now.alert = "Veuillez remplir les champs obligatoires."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def load_quote_context
    @products = public_product_cards.order(:name).limit(80).to_a
    @destock_products = public_destock_products
                       .includes(:category, :options, images_attachments: :blob)
                       .order(:name)
                       .limit(40)
                       .to_a
    @quote_products = (@products + @destock_products).uniq
    @selected_product = @quote_products.find { |product| product.id.to_s == params[:product_id].to_s }
  end

  def build_quote_page(quote)
    PublicV2::QuotePage.new(
      quote: quote,
      products: @quote_products,
      selected_product: @selected_product,
      selected_product_image: public_v2_primary_image(@selected_product)
    )
  end

  def quote_params
    params.require(:quote).permit(:product, :lastname, :email, :phone, :message, :city, :address)
  end
end
