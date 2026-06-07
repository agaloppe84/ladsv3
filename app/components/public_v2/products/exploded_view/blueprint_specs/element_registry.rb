# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class ElementRegistry
          Entry = Struct.new(:type, :variant, :renderer_family, :status, keyword_init: true) do
            def key
              ElementRegistry.key(type, variant)
            end
          end

          DEFAULT_ENTRIES = [
            Entry.new(type: "bar", variant: "bottom-charge", renderer_family: "solid_bar_profile", status: "supported"),
            Entry.new(type: "bar", variant: "roll-tube", renderer_family: "solid_bar_profile", status: "supported"),
            Entry.new(type: "bar", variant: "threshold", renderer_family: "solid_bar_profile", status: "supported"),
            Entry.new(type: "bar", variant: "vertical-handle", renderer_family: "solid_bar_profile", status: "supported"),
            Entry.new(type: "bar", variant: "zipped-load", renderer_family: "solid_bar_profile", status: "supported"),
            Entry.new(type: "closure", variant: "magnetic-receivers", renderer_family: "solid_accessory_profile", status: "supported"),
            Entry.new(type: "closure", variant: "plissee-lock", renderer_family: "solid_accessory_profile", status: "supported"),
            Entry.new(type: "closure", variant: "rail-bavettes", renderer_family: "solid_accessory_profile", status: "supported"),
            Entry.new(type: "control", variant: "bead-chain", renderer_family: "solid_control_profile", status: "supported"),
            Entry.new(type: "control", variant: "cord-pair", renderer_family: "solid_control_profile", status: "supported"),
            Entry.new(type: "control", variant: "venetian-wand", renderer_family: "solid_control_profile", status: "supported"),
            Entry.new(type: "fabric", variant: "bordered-grid-solid", renderer_family: "fabric_pattern", status: "supported"),
            Entry.new(type: "fabric", variant: "duo-bands-solid", renderer_family: "fabric_pattern", status: "supported"),
            Entry.new(type: "fabric", variant: "honeycomb-solid", renderer_family: "fabric_pattern", status: "supported"),
            Entry.new(type: "fabric", variant: "pleated-solid", renderer_family: "fabric_pattern", status: "supported"),
            Entry.new(type: "fabric", variant: "zipped-solid", renderer_family: "fabric_pattern", status: "supported"),
            Entry.new(type: "housing", variant: "front-coffre", renderer_family: "solid_housing_profile", status: "supported"),
            Entry.new(type: "housing", variant: "kiss-50-cassette", renderer_family: "solid_housing_profile", status: "supported"),
            Entry.new(type: "motor", variant: "tubular", renderer_family: "solid_motor_profile", status: "supported"),
            Entry.new(type: "rail", variant: "duette-head", renderer_family: "solid_bar_profile", status: "supported"),
            Entry.new(type: "rail", variant: "double-coulisse-pair", renderer_family: "solid_profile", status: "supported"),
            Entry.new(type: "rail", variant: "horizontal-guide", renderer_family: "solid_profile", status: "supported"),
            Entry.new(type: "rail", variant: "profile-pair", renderer_family: "solid_profile", status: "supported"),
            Entry.new(type: "rail", variant: "zipped-coulisse-pair", renderer_family: "solid_profile", status: "supported"),
            Entry.new(type: "slat", variant: "venetian-pack", renderer_family: "slat_pattern", status: "supported"),
            Entry.new(type: "support", variant: "mount-pair", renderer_family: "solid_support_profile", status: "supported")
          ].freeze

          def self.default
            new(DEFAULT_ENTRIES)
          end

          def self.key(type, variant)
            "#{type}:#{variant}"
          end

          def initialize(entries = DEFAULT_ENTRIES)
            @entries = entries.each_with_object({}) do |entry, index|
              index[entry.key] = entry
            end
          end

          def fetch(type, variant)
            entries.fetch(self.class.key(type, variant))
          end

          def registered?(type, variant)
            entries.key?(self.class.key(type, variant))
          end

          def supported?(type, variant)
            entry = entries[self.class.key(type, variant)]

            entry&.status == "supported"
          end

          def keys
            entries.keys.sort
          end

          private

          attr_reader :entries
        end
      end
    end
  end
end
