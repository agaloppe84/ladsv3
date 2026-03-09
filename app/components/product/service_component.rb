# frozen_string_literal: true

class Product::ServiceComponent < ViewComponent::Base
  COMMON_ICON_CLASS = "h-5 w-5 stroke-current fill-none"

  def initialize(service:)
    @service = service
  end

  def render?
    @service.present? && features.any?
  end

  private

  def features
    return [] unless @service

    @features ||= begin
      list = []

      if @service.warranty
        label = @service.product.warranty.present? ? "Garantie #{@service.product.warranty} ans" : "Garantie"
        list << {
          label: label,
          icon: "icons/warranty.svg",
          icon_class: COMMON_ICON_CLASS,
          tone_class: "border-amber-200 bg-gradient-to-br from-amber-50 to-amber-100 text-amber-700"
        }
      end

      if @service.custom_dimensions
        list << {
          label: "Sur mesure",
          icon: "icons/ruler.svg",
          icon_class: COMMON_ICON_CLASS,
          tone_class: "border-sky-200 bg-gradient-to-br from-sky-50 to-sky-100 text-sky-700"
        }
      end

      if @service.anti_fire
        list << {
          label: "Anti feu",
          icon: "icons/fire.svg",
          icon_class: COMMON_ICON_CLASS,
          tone_class: "border-orange-200 bg-gradient-to-br from-orange-50 to-rose-100 text-orange-700"
        }
      end

      if @service.wind_resistance
        list << {
          label: "Résistance vent",
          icon: "icons/wind.svg",
          icon_class: COMMON_ICON_CLASS,
          tone_class: "border-cyan-200 bg-gradient-to-br from-cyan-50 to-sky-100 text-cyan-700"
        }
      end

      if @service.anti_uv
        list << {
          label: "Anti UV",
          icon: "icons/anti-uv.svg",
          icon_class: "h-5 w-5 fill-current",
          tone_class: "border-violet-200 bg-gradient-to-br from-violet-50 to-fuchsia-100 text-violet-700"
        }
      end

      if @service.made_in_france
        list << {
          label: "Made in France",
          icon: "icons/french-flag.svg",
          icon_class: "h-5 w-5",
          tone_class: "border-slate-200 bg-gradient-to-br from-white to-slate-100 text-slate-700"
        }
      end

      if @service.free_quote
        list << {
          label: "Devis gratuit",
          icon: "icons/banknotes.svg",
          icon_class: COMMON_ICON_CLASS,
          tone_class: "border-emerald-200 bg-gradient-to-br from-emerald-50 to-teal-100 text-emerald-700"
        }
      end

      if @service.rge
        list << {
          label: "Qualifié RGE",
          icon: "icons/shield-check.svg",
          icon_class: COMMON_ICON_CLASS,
          tone_class: "border-lime-200 bg-gradient-to-br from-lime-50 to-emerald-100 text-lime-700"
        }
      end

      list
    end
  end
end
