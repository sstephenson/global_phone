require 'global_phone/number'
require 'global_phone/utils'

module GlobalPhone
  module Parsing
    def parse(string, territory_name)
      string = Number.normalize(string)
      territory = self.territory(territory_name)
      raise ArgumentError, "unknown territory `#{territory_name}'" unless territory

      if starts_with_plus?(string)
        parse_international_string(string)
      elsif string =~ territory.international_prefix
        string = strip_international_prefix(territory, string)
        parse_international_string(string)
      else
        territory.parse_national_string(string)
      end
    end

    def parse_international_string(string)
      string = Number.normalize(string)
      string = strip_leading_plus(string) if starts_with_plus?(string)

      if region = region_for_string(string)
        region.parse_national_string(string)
      end
    end

    protected
      def starts_with_plus?(string)
        string[0, 1] == "+"
      end

      def strip_leading_plus(string)
        string[1..-1]
      end

      def strip_international_prefix(territory, string)
        string.sub(territory.international_prefix, "")
      end

      def region_for_string(string)
        candidates = country_code_candidates_for(string)
        Utils.map_detect(candidates) { |country_code| region(country_code) }
      end

      def country_code_candidates_for(string)
        (1..3).map { |length| string[0, length] }
      end
  end
end
