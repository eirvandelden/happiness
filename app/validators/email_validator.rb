# Validates that an attribute contains a valid email address.
#
# @example
#   validates :email, email: true
#   validates :contact_email, email: true, allow_blank: true
class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

  # Validates a single attribute value.
  #
  # @param record [ActiveRecord::Base] the model being validated
  # @param attribute [Symbol] the attribute name being validated
  # @param value [String] the value to validate
  # @return [void]
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value.match?(EMAIL_REGEX)
      record.errors.add(attribute, :invalid, value: value)
    end
  end
end
