require 'global_phone/format'
require 'global_phone/record'
require 'global_phone/territory'
require 'global_phone/utils'

module GlobalPhone
  class Region < Record
    field 0, :country_code
    field 1, :format_record_data
    field 2, :territory_record_data
    field 3, :international_prefix do |p| /^(?:#{p})/ end
    field 4, :national_prefix
    field 5, :national_prefix_for_parsing do |p| /^(?:#{p})/ end
    field 6, :national_prefix_transform_rule

    def formats
      @formats ||= format_record_data.map { |data| Format.new(data) }
    end

    def territories
      @territories ||= territory_record_data.map { |data| Territory.new(data, self) }
    end

    def territory(name)
      name = name.to_s.upcase
      territories.detect { |region| region.name == name }
    end

    def has_territory?(name)
      territory_names.include?(name.to_s.upcase)
    end

    def parse_national_string(string)
      string = Number.normalize(string)
      if starts_with_country_code?(string)
        string = strip_country_code(string)
        find_first_parsed_national_string_from_territories(string)
      end
    end

    def inspect
      "#<#{self.class.name} country_code=#{country_code} territories=[#{territory_names.join(",")}]>"
    end

    protected
      def territory_names
        territory_record_data.map(&:first)
      end

      def starts_with_country_code?(string)
        string.index(country_code) == 0
      end

      def strip_country_code(string)
        string[country_code.length..-1]
      end

      def find_first_parsed_national_string_from_territories(string)
        first = nil
        territories.each do |territory|
          if number = territory.parse_national_string(string)
            return number if number.valid?
            first ||= number
          end
        end
        first
      end
  end
end
