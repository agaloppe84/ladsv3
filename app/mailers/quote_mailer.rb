class QuoteMailer < ApplicationMailer

  def new_quote
    @quote = params[:quote]
    mail(
      to:      'ads.pascale@lesartisansdustore.com',
      from:    'ads.pascale@lesartisansdustore.com',
      subject: "Nouvelle demande de devis de #{@quote.lastname}"
    )
  end
end
