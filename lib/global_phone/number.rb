require 'forwardable'

module GlobalPhone
  class Number
    extend Forwardable

    E161_MAPPING       = Hash[*"a2b2c2d3e3f3g4h4i4j5k5l5m6n6o6p7q7r7s7t8u8v8w9x9y9z9".split("")]
    VALID_ALPHA_CHARS  = /[a-zA-Z]/
    LEADING_PLUS_CHARS = /^\++/
    NON_DIALABLE_CHARS = /[^,#+\*\d]/
    SPLIT_FIRST_GROUP  = /^(\d+)(.*)$/

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
        if format && result = format.apply(national_string, :national)
          apply_national_prefix_format(result)
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

    def valid?
      territory.valid?(national_string)
    end

    def inspect
      "#<#{self.class.name} territory=#{territory.inspect} national_string=#{national_string.inspect}>"
    end

    def to_s
      international_string
    end

    protected

    def format
      @format ||= region.formats.detect { |format| format.match(national_string) }
    end

      def apply_national_prefix_format(result)
        prefix = national_prefix_formatting_rule
        return result unless prefix && match = result.match(SPLIT_FIRST_GROUP)

        prefix = prefix.gsub("$NP", national_prefix)
        prefix = prefix.gsub("$FG", match[1])
        result = "#{prefix} #{match[2]}"
      end

      def national_prefix_formatting_rule
        format.national_prefix_formatting_rule || territory.national_prefix_formatting_rule
      end
  end
end
