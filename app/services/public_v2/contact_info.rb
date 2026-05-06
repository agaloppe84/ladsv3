# frozen_string_literal: true

class PublicV2::ContactInfo
  PHONE = "04 74 01 05 11"
  EMAIL = "ads.pascale@lesartisansdustore.com"
  ADDRESS = "35 Rue des Martinets"
  CITY = "69210 L'Arbresle"
  EYEBROW = "Les Artisans du Store · L'Arbresle"
  HOURS_TEXT = "Du lundi au vendredi, 9h a 18h30."
  SUMMARY_TEXT = "Showroom de 200m2 a L'Arbresle, conseil technique, prise de cotes, pose et suivi SAV pour les projets de protection solaire et fermeture."
  PROOF_ITEMS = ["Conseil technique", "Prise de cotes", "Pose soignée", "Suivi SAV"].freeze
  MAP_SRC = "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2780.2835652333556!2d4.604221976642868!3d45.82560487108219!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x47f48b472a3cbe87%3A0xb8e782d7f52576e0!2sLes%20Artisans%20du%20Store!5e0!3m2!1sfr!2sfr!4v1742294949861!5m2!1sfr!2sfr"

  class << self
    def phone
      PHONE
    end

    def email
      EMAIL
    end

    def address
      ADDRESS
    end

    def city
      CITY
    end

    def full_address
      "#{address}, #{city}"
    end

    def eyebrow
      EYEBROW
    end

    def hours_text
      HOURS_TEXT
    end

    def summary_text
      SUMMARY_TEXT
    end

    def proof_items
      PROOF_ITEMS
    end

    def phone_href
      "tel:#{phone.delete(" ")}"
    end

    def email_href
      "mailto:#{email}"
    end

    def map_src
      MAP_SRC
    end

    def contact_cards
      [
        { label: "Adresse", title: address, text: "#{city}, Rhone" },
        { label: "Telephone", title: phone, text: "Premier contact, prise de rendez-vous showroom ou suivi de dossier.", path: phone_href },
        { label: "Email", title: email, text: "Pour envoyer les elements du projet, photos, dimensions ou contraintes.", path: email_href },
        { label: "Horaires", title: "Lundi au vendredi", text: "9h - 18h30, showroom de 200m2 a L'Arbresle." }
      ]
    end

    def quote_contact_items
      [
        { label: "Telephone", value: phone, path: phone_href },
        { label: "Email", value: email, path: email_href },
        { label: "Showroom", value: full_address }
      ]
    end
  end
end
