require 'global_phone/record'

module GlobalPhone
  class Format < Record
    field 0, :pattern do |p| /^#{p}$/ end
    field 1, :national_format_rule
    field 2, :leading_digits do |d| /^#{d}/ end
    field 3, :national_prefix_formatting_rule
    field 4, :international_format_rule, :fallback => :national_format_rule

    def match(national_string, match_leading_digits = true)
      return false if match_leading_digits && leading_digits && national_string !~ leading_digits
      if match = pattern.match(national_string)
        return match[0].length == national_string.length
      end
      false
    end

    def format_replacement_string(type)
      format_rule = send(:"#{type}_format_rule")
      format_rule.to_s.gsub("$", "\\") unless format_rule == "NA"
    end

    def apply(national_string, type)
      if replacement = format_replacement_string(type)
        national_string.gsub(pattern, replacement)
      end
    end
  end
end
