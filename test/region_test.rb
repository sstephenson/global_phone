require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class RegionTest < TestCase
    test "tries to find valid territory if multiple territories match" do
      string = '77772251111'
      national_string = string[1..-1]
      region = context.db.region '7'
      territories = region.territories

      # Check that the test data is still relevant.
      territories.each do |territory|
        assert territory.parse_national_string national_string
      end

      refute territories.first.parse_national_string(national_string).valid?
      assert territories.last.parse_national_string(national_string).valid?

      # Check that the correct territory is picked.
      number = region.parse_national_string string
      assert number.valid?
    end
  end
end
