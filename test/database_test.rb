require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class DatabaseTest < TestCase
    test "initializing database manually" do
      db = Database.new(record_data)
      assert_equal record_data.size, db.regions.size
    end

    test "finding region by country code" do
      region = db.region(1)
      assert_kind_of Region, region
      assert_equal "1", region.country_code
    end

    test "nonexistent region returns nil" do
      assert_nil db.region(999)
    end

    test "finding territory by name" do
      territory = db.territory(:gb)
      assert_kind_of Territory, territory
      assert_equal "GB", territory.name
      assert_equal db.region(44), territory.region
    end

    test "nonexistent territory returns nil" do
      assert_nil db.territory("nonexistent")
    end
  end
end
