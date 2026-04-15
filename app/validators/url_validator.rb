# Validates that an attribute contains a valid HTTP(S) URL.
#
# @example
#   validates :website, url: true
#   validates :homepage, url: true, allow_blank: true
class UrlValidator < ActiveModel::EachValidator
  # Validates a single attribute value.
  #
  # @param record [ActiveRecord::Base] the model being validated
  # @param attribute [Symbol] the attribute name being validated
  # @param value [String] the value to validate
  # @return [void]
  def validate_each(record, attribute, value)
    return if value.blank?

    begin
      uri = URI.parse(value)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        record.errors.add(attribute, :invalid, value: value)
      end
    rescue URI::InvalidURIError
      record.errors.add(attribute, :invalid, value: value)
    end
  end
end
