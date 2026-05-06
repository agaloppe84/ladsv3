# frozen_string_literal: true

module PublicV2::Debuggable
  private

  def debug?
    defined?(@debug) && @debug.present?
  end

  def debug_class
    "pv2-debug-frame" if debug?
  end

  def debug_data
    return {} unless debug?

    { pv2_debug_component: debug_component_name }
  end

  def with_debug_data(data)
    data.to_h.merge(debug_data)
  end

  def debug_attributes
    return unless debug?

    helpers.tag.attributes(data: debug_data)
  end

  def debug_component_name
    self.class.name.delete_prefix("PublicV2::")
  end
end
