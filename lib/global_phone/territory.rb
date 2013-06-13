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
    field 19, :fixedLine_possible_pattern do |p| /^#{p}$/ end
    field 20, :fixedLine_national_pattern do |p| /^#{p}$/ end
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
      Number.new(self, string) if possible?(string)
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
        string =~ general_desc_possible_pattern
      end

      def starts_with_national_prefix?(string)
        national_prefix && string.index(national_prefix) == 0
      end
  end
end
