module OptionContentHelper
  OPTION_CONTENT_ALLOWED_TAGS = %w[strong b].freeze
  OPTION_CONTENT_ALLOWED_ATTRIBUTES = [].freeze

  def formatted_option_content(content)
    sanitize(
      content.to_s,
      tags: OPTION_CONTENT_ALLOWED_TAGS,
      attributes: OPTION_CONTENT_ALLOWED_ATTRIBUTES
    )
  end

  def option_content_plain_text(content)
    strip_tags(formatted_option_content(content)).squish
  end
end
