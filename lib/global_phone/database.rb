require 'json'
require 'global_phone/region'

module GlobalPhone
  class Database
    attr_reader :regions

    def self.load_file(filename)
      load(File.read(filename))
    end

    def self.load(json)
      new(JSON.parse(json))
    end

    def initialize(record_data)
      @regions = record_data.map { |data| Region.new(data) }
      @territories_by_name = {}
    end

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

    def region(country_code)
      regions_by_country_code[country_code.to_s]
    end

    def territory(name)
      name = name.to_s.upcase
      @territories_by_name[name] ||= if region = region_for_territory(name)
        region.territory(name)
      end
    end

    def inspect
      "#<#{self.class.name}>"
    end

    def region_for_string(string)
      country_code_candidates_for(strip_leading_plus(string)).each do |country_code|
        if found_region = region(country_code)
          return found_region
        end
      end
      nil
    end

    private

    def parse_international_string(string)
      string = strip_leading_plus(Number.normalize(string))

      if region = region_for_string(string)
        region.parse_national_string(string)
      end
    end

    def starts_with_plus?(string)
      string[0, 1] == "+"
    end

    def strip_leading_plus(string)
      if starts_with_plus?(string)
        string[1..-1]
      else
        string
      end
    end

    def strip_international_prefix(territory, string)
      string.sub(territory.international_prefix, "")
    end

    def country_code_candidates_for(string)
      (1..3).map { |length| string[0, length] }
    end

    def regions_by_country_code
      @regions_by_country_code ||= Hash[*regions.map { |r| [r.country_code, r] }.flatten]
    end

    def region_for_territory(name)
      regions.find { |r| r.has_territory?(name) }
    end
  end
end
