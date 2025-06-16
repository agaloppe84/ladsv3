class Quote < ApplicationRecord
  validates_presence_of :email, :lastname, :address, :city, :phone, :product, :message
  after_create_commit :send_new_quote_email

  private

  def send_new_quote_email
    QuoteMailer
      .with(quote: self)
      .new_quote
      .deliver_later
  end
end
