require 'global_phone/number'
require 'global_phone/record'

module GlobalPhone
  class Territory < Record
    field 0, :name
    field 1, :general_desc_possible_pattern do |p| /^#{p}$/ end
    field 2, :general_desc_national_pattern do |p| /^#{p}$/ end
    field 3, :premium_rate_possible_pattern do |p| /^#{p}$/ end
    field 4, :premium_rate_national_pattern do |p| /^#{p}$/ end
    field 5, :toll_free_possible_pattern do |p| /^#{p}$/ end
    field 6, :toll_free_national_pattern do |p| /^#{p}$/ end
    field 7, :shared_cost_possible_pattern do |p| /^#{p}$/ end
    field 8, :shared_cost_national_pattern do |p| /^#{p}$/ end
    field 9, :voip_possible_pattern do |p| /^#{p}$/ end
    field 10, :voip_national_pattern do |p| /^#{p}$/ end
    field 11, :personal_number_possible_pattern do |p| /^#{p}$/ end
    field 12, :personal_number_national_pattern do |p| /^#{p}$/ end
    field 13, :pager_possible_pattern do |p| /^#{p}$/ end
    field 14, :pager_national_pattern do |p| /^#{p}$/ end
    field 15, :uan_possible_pattern do |p| /^#{p}$/ end
    field 16, :uan_national_pattern do |p| /^#{p}$/ end
    field 17, :voicemail_possible_pattern do |p| /^#{p}$/ end
    field 18, :voicemail_national_pattern do |p| /^#{p}$/ end
    field 19, :fixed_line_possible_pattern do |p| /^#{p}$/ end
    field 20, :fixed_line_national_pattern do |p| /^#{p}$/ end
    field 21, :mobile_possible_pattern do |p| /^#{p}$/ end
    field 22, :mobile_national_pattern do |p| /^#{p}$/ end
    field 23, :national_prefix_formatting_rule

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
      @number_type = number_type(string)
      Number.new(self, string, @number_type) if possible?(string)
    end

    def inspect
      "#<#{self.class.name} country_code=#{country_code} name=#{name}>"
    end

    protected
      def strip_national_prefix(string)
        if national_prefix_for_parsing
          transform_rule = national_prefix_transform_rule || ""
          transform_rule = transform_rule.gsub("$", "\\")
          string_without_prefix = string.sub(national_prefix_for_parsing, transform_rule)
        elsif starts_with_national_prefix?(string)
          string_without_prefix = string[national_prefix.length..-1]
        end

        possible?(string_without_prefix) ? string_without_prefix : string
      end

      def normalize(string)
        strip_national_prefix(Number.normalize(string))
      end

      def possible?(string)
        :unknown != number_type(string)
      end

      def number_type(string)
        return :unknown if !general_desc_national_pattern || !number_matching_desc?(string, general_desc_possible_pattern, general_desc_national_pattern)
        return :premium_rate if number_matching_desc?(string, premium_rate_possible_pattern, premium_rate_national_pattern)
        return :toll_free if number_matching_desc?(string, toll_free_possible_pattern, toll_free_national_pattern)
        return :shared_cost if number_matching_desc?(string, shared_cost_possible_pattern, shared_cost_national_pattern)
        return :voip if number_matching_desc?(string, voip_possible_pattern, voip_national_pattern)
        return :personal_number if number_matching_desc?(string, personal_number_possible_pattern, personal_number_national_pattern)
        return :pager if number_matching_desc?(string, pager_possible_pattern, pager_national_pattern)
        return :uan if number_matching_desc?(string, uan_possible_pattern, uan_national_pattern)
        return :voicemail if number_matching_desc?(string, voicemail_possible_pattern, voicemail_national_pattern)
        if number_matching_desc?(string, fixed_line_possible_pattern, fixed_line_national_pattern)
          if number_matching_desc?(string, mobile_possible_pattern, mobile_national_pattern)
            return :fixed_line_or_mobile
          else
            return :fixed_line
          end
        end
        return :mobile if number_matching_desc?(string, mobile_possible_pattern, mobile_national_pattern)
        :unknown
      end

      def number_matching_desc?(string, possible_pattern, national_pattern)
        string =~ /^#{possible_pattern ? possible_pattern : general_desc_possible_pattern}$/ && string =~ /^#{national_pattern}$/
      end

      def starts_with_national_prefix?(string)
        national_prefix && string.index(national_prefix) == 0
      end
  end
end
