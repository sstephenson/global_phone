require 'global_phone/parsing'
require 'global_phone/region'

module GlobalPhone
  class Database
    include Parsing

    def self.load_file(filename)
      load(File.read(filename))
    end

    def self.load(json)
      require 'json'
      new(JSON.parse(json))
    end

    attr_reader :regions

    def initialize(record_data)
      @regions = record_data.map { |data| Region.new(data) }
      @territories_by_name = {}
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

    protected
      def regions_by_country_code
        @regions_by_country_code ||= Hash[*regions.map { |r| [r.country_code, r] }.flatten]
      end

      def region_for_territory(name)
        regions.find { |r| r.has_territory?(name) }
      end
  end
end
