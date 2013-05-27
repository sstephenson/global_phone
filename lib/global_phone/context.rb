require 'global_phone/database'

module GlobalPhone
  module Context
    attr_accessor :db_path

    def db
      @db ||= begin
        raise NoDatabaseError, "set `db_path=' first" unless db_path
        Database.load_file(db_path)
      end
    end

    def default_territory_name
      @default_territory_name ||= :US
    end

    def default_territory_name=(territory_name)
      @default_territory_name = territory_name.to_s.intern
    end

    def parse(string, territory_name = default_territory_name)
      db.parse(string, territory_name)
    end

    def normalize(string, territory_name = default_territory_name)
      number = parse(string, territory_name)
      number.international_string if number
    end

    def validate(string, territory_name = default_territory_name)
      number = parse(string, territory_name)
      number && number.valid?
    end
  end
end
