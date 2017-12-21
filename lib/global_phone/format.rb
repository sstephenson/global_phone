require 'global_phone/record'

module GlobalPhone
  class Format < Record
    field 0, :pattern do |p| /^#{p}$/ end
    field 1, :national_format_rule
    field 2, :leading_digits do |d| /^#{d}/ end
    field 3, :national_prefix_formatting_rule
    field 4, :international_format_rule, :fallback => :national_format_rule

    def match(national_string)
      return false if leading_digits && national_string !~ leading_digits
      national_string =~ pattern
    end

    def format_replacement_string(type)
      format_rule = send(:"#{type}_format_rule")
      format_rule.tr("$", "\\") if format_rule && format_rule != "NA"
    end

    def apply(national_string, type)
      if replacement = format_replacement_string(type)
        national_string.gsub(pattern, replacement)
      end
    end
  end
end
