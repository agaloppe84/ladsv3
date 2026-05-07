# frozen_string_literal: true

class PublicV2::Layout::FooterComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(categories: [], title: "Un projet de store, volet ou fermeture ?", text: nil, phone: PublicV2::ContactInfo.phone, email: PublicV2::ContactInfo.email, eyebrow: PublicV2::ContactInfo.eyebrow, address: PublicV2::ContactInfo.address, city: PublicV2::ContactInfo.city, proof_items: PublicV2::ContactInfo.proof_items, id: "contact", classes: nil)
    @categories = categories
    @title = title
    @text = text.presence || PublicV2::ContactInfo.summary_text
    @phone = phone
    @email = email
    @eyebrow = eyebrow
    @address = address
    @city = city
    @proof_items = proof_items.presence || PublicV2::ContactInfo.proof_items
    @id = id
    @classes = classes
  end

  private

  attr_reader :categories, :title, :text, :phone, :email, :eyebrow, :address, :city, :proof_items, :id, :classes

  def component_classes
    ["pv2-public-footer", "pv2-ui-footer", "grid w-full min-w-0 gap-[1.2rem]", debug_class, classes].compact.join(" ")
  end

  def phone_href
    "tel:#{phone.to_s.delete(" ")}"
  end

  def mail_href
    "mailto:#{email}"
  end
end
