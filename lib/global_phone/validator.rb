I18n.load_path << File.dirname(__FILE__) + '/locale/phone_number_validator.en.yml'

class GlobalPhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    args = [value]
    if (using = options[:using]) && (country_code = record.send(using))
      args << country_code
    end
    unless GlobalPhone.validate(*args)
      record.errors.add attribute, :invalid_phone_number, country_code: country_code
    end
  end
end
