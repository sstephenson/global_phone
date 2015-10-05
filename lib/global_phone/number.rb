require 'forwardable'

module GlobalPhone
  class Number
    extend Forwardable

    E161_MAPPING       = Hash[*"a2b2c2d3e3f3g4h4i4j5k5l5m6n6o6p7q7r7s7t8u8v8w9x9y9z9".split("")]
    VALID_ALPHA_CHARS  = /[a-zA-Z]/
    LEADING_PLUS_CHARS = /^\++/
    NON_DIALABLE_CHARS = /[^,#+\*\d]/
    SPLIT_FIRST_GROUP  = /^(\d+)\W*(.*)$/

    def self.normalize(string)
      string.to_s.
        gsub(VALID_ALPHA_CHARS) { |c| E161_MAPPING[c.downcase] }.
        gsub(LEADING_PLUS_CHARS, "+").
        gsub(NON_DIALABLE_CHARS, "")
    end

    attr_reader :territory, :national_string

    def_delegator :territory, :region
    def_delegator :territory, :country_code
    def_delegator :territory, :national_prefix
    def_delegator :territory, :national_pattern

    def initialize(territory, national_string)
      @territory = territory
      @national_string = national_string
    end

    def national_format
      @national_format ||= begin
        if format
          national_string_with_prefix
        else
          national_string
        end
      end
    end

    def international_string
      @international_string ||= international_format.gsub(NON_DIALABLE_CHARS, "")
    end

    def international_format
      @international_format ||= begin
        if format && formatted_number = format.apply(national_string, :international)
          "+#{country_code} #{formatted_number}"
        else
          "+#{country_code} #{national_string}"
        end
      end
    end

    def area_code
      @area_code ||= formatted_national_prefix.gsub(/[^\d]/, '') if formatted_national_prefix
    end

    def local_number
      @local_number ||= area_code ? national_string_parts[2] : national_format
    end

    def valid?
      !!(format && national_string =~ national_pattern)
    end

    def inspect
      "#<#{self.class.name} territory=#{territory.inspect} national_string=#{national_string.inspect}>"
    end

    def to_s
      international_string
    end

    protected
      def format
        @format ||= find_format_for(national_string)
      end

      def find_format_for(string)
        region.formats.detect { |format| format.match(string) } ||
        region.formats.detect { |format| format.match(string, false) }
      end

      def formatted_national_string
        @formatted_national_string ||= format.apply(national_string, :national)
      end

      def national_string_parts
        @national_string_parts ||= formatted_national_string.match(SPLIT_FIRST_GROUP)
      end

      def area_code_suffix
        @area_code_suffix ||= national_string_parts[1]
      end

      def formatted_national_prefix
        @formatted_national_prefix ||= begin
          national_prefix_formatting_rule.gsub("$NP", national_prefix).gsub("$FG", area_code_suffix) if
            national_prefix_formatting_rule
        end
      end

      def national_string_with_prefix
        @national_string_with_prefix ||= national_prefix_formatting_rule && national_string_parts ?
          "#{formatted_national_prefix} #{local_number}" : formatted_national_string
      end

      def national_prefix_formatting_rule
        @national_prefix_formatting_rule ||=
          format.national_prefix_formatting_rule || territory.national_prefix_formatting_rule
      end
  end
end
