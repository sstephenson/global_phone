require 'global_phone/number'
require 'global_phone/record'

module GlobalPhone
  class Territory < Record
    field 0, :name
    field 1, :possible_pattern do |p| /^#{p}$/ end
    field 2, :national_pattern do |p| /^#{p}$/ end
    field 3, :national_prefix_formatting_rule

    attr_reader :region

    def_delegator :region, :country_code
    def_delegator :region, :international_prefix
    def_delegator :region, :national_prefix
    def_delegator :region, :national_prefix_for_parsing
    def_delegator :region, :national_prefix_transform_rule

    def initialize(data, region)
      super(data)
      @region = region
    end

    def parse_national_string(string)
      string = normalize(string)
      Number.new(self, string) if possible?(string)
    end

    def inspect
      "#<#{self.class.name} country_code=#{country_code} name=#{name}>"
    end

    protected
      def strip_prefixes(string)
        if national_prefix_for_parsing
          transform_rule = national_prefix_transform_rule || ""
          transform_rule = transform_rule.gsub("$", "\\")
          string_without_prefix = string.sub(national_prefix_for_parsing, transform_rule)
        elsif starts_with_national_prefix?(string)
          string_without_prefix = string[national_prefix.length..-1]
        elsif !possible?(string) && starts_with_country_code?(string)
          string_without_prefix = string[country_code.length..-1]
        end

        possible?(string_without_prefix) ? string_without_prefix : string
      end

      def normalize(string)
        strip_prefixes(Number.normalize(string))
      end

      def possible?(string)
        string =~ possible_pattern
      end

      def starts_with_national_prefix?(string)
        national_prefix && string.index(national_prefix) == 0
      end

      def starts_with_country_code?(string)
        country_code && string.index(country_code) == 0
      end
  end
end
