require 'global_phone/number'
require 'global_phone/record'

module GlobalPhone
  class Territory < Record
    field 0, :name
    field 1, :national_pattern do |p| /^#{p}$/ end
    field 2, :national_prefix_formatting_rule
    field 3, :possible_lengths
    field 4, :fixed_line_pattern do |p| /^#{p}$/ end
    field 5, :mobile_pattern do |p| /^#{p}$/ end
    field 6, :pager_pattern do |p| /^#{p}$/ end
    field 7, :toll_free_pattern do |p| /^#{p}$/ end
    field 8, :premium_rate_pattern do |p| /^#{p}$/ end
    field 9, :shared_cost_pattern do |p| /^#{p}$/ end
    field 10, :personal_number_pattern do |p| /^#{p}$/ end
    field 11, :voip_pattern do |p| /^#{p}$/ end
    field 12, :uan_pattern do |p| /^#{p}$/ end
    field 13, :voicemail_pattern do |p| /^#{p}$/ end

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
      full_number_string = Number.normalize(string)
      potential_national_string = strip_prefixes(full_number_string)
      national_number_string = if !national_number?(full_number_string) && national_number?(potential_national_string)
        potential_national_string
      else
        full_number_string
      end
      Number.new(self, national_number_string) if possible?(national_number_string)
    end

    def valid?(string)
      return false unless national_number?(string)

      return true if fixed_line_pattern && string =~ fixed_line_pattern
      return true if mobile_pattern && string =~ mobile_pattern
      return true if pager_pattern && string =~ pager_pattern
      return true if toll_free_pattern && string =~ toll_free_pattern
      return true if premium_rate_pattern && string =~ premium_rate_pattern
      return true if shared_cost_pattern && string =~ shared_cost_pattern
      return true if personal_number_pattern && string =~ personal_number_pattern
      return true if voip_pattern && string =~ voip_pattern
      return true if uan_pattern && string =~ uan_pattern
      return true if voicemail_pattern && string =~ voicemail_pattern

      false
    end

    def inspect
      "#<#{self.class.name} country_code=#{country_code} name=#{name}>"
    end

    protected

    def national_number?(string)
      possible?(string) && string =~ national_pattern
    end

      def strip_prefixes(string)
        if national_prefix_for_parsing
          transform_rule = national_prefix_transform_rule || ""
          transform_rule = transform_rule.gsub("$", "\\")
          string_without_prefix = string.sub(national_prefix_for_parsing, transform_rule)
        elsif starts_with_national_prefix?(string)
          string_without_prefix = string[national_prefix.length..-1]
        elsif starts_with_country_code?(string)
          string_without_prefix = string[country_code.length..-1]
        end

        possible?(string_without_prefix) ? string_without_prefix : string
      end

      def possible?(string)
        string && possible_lengths && possible_lengths.include?(string.size)
      end

      def starts_with_national_prefix?(string)
        national_prefix && string.index(national_prefix) == 0
      end

      def starts_with_country_code?(string)
        country_code && string.index(country_code) == 0
      end
  end
end
