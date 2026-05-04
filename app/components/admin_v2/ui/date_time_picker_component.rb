# frozen_string_literal: true

class AdminV2::Ui::DateTimePickerComponent < ViewComponent::Base
  WEEKDAYS = %w[L M M J V S D].freeze

  def initialize(form:, attribute:, label:, value:, autosave: false, minute_step: 15, id: nil)
    @form = form
    @attribute = attribute
    @label = label
    @value = value
    @autosave = autosave
    @minute_step = minute_step
    @id = id
  end

  private

  attr_reader :form, :attribute, :label, :value, :minute_step

  def input_id
    @input_id ||= @id || "admin_v2_#{form.object_name}_#{attribute}"
  end

  def panel_id
    "#{input_id}_calendar"
  end

  def iso_value
    value&.strftime("%Y-%m-%dT%H:%M")
  end

  def display_date
    return "Non défini" unless value

    value.strftime("%d/%m/%Y")
  end

  def display_time
    return "--:--" unless value

    value.strftime("%H:%M")
  end

  def input_data
    data = { date_time_picker_target: "input" }
    data[:action] = "change->autosave-field#submit" if @autosave
    data
  end
end
