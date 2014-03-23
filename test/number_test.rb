require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class NumberTest < TestCase
    test "valid number" do
      number = context.parse("(312) 555-1212")
      assert number.valid?
    end

    test "invalid number" do
      number = context.parse("555-1212")
      assert !number.valid?
    end

    test "country_code" do
      number = context.parse("(312) 555-1212")
      assert_equal "1", number.country_code

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal "44", number.country_code
    end

    test "region" do
      number = context.parse("(312) 555-1212")
      assert_equal db.region(1), number.region

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal db.region(44), number.region
    end

    test "territory" do
      number = context.parse("(312) 555-1212")
      assert_equal db.territory(:us), number.territory

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal db.territory(:gb), number.territory
    end

    test "national_string" do
      number = context.parse("(312) 555-1212")
      assert_equal "3125551212", number.national_string
    end

    test "national_format" do
      number = context.parse("312-555-1212")
      assert_equal "(312) 555-1212", number.national_format
    end

    test "international_string" do
      number = context.parse("(312) 555-1212")
      assert_equal "+13125551212", number.international_string
      assert_equal number.international_string, number.to_s
    end

    test "international_format" do
      number = context.parse("(312) 555-1212")
      assert_equal "+1 312-555-1212", number.international_format
    end

    test "area_code" do
      number = context.parse("+61 3 9876 0010")
      assert_equal "03", number.area_code

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal "020", number.area_code

      # Hong Kong has no area code
      number = context.parse("+852 2699 2838")
      assert_equal nil, number.area_code
    end

    test "local_number" do
      number = context.parse("+61 3 9876 0010")
      assert_equal "9876 0010", number.local_number

      number = context.parse("+44 (0) 20-7031-3000")
      assert_equal "7031 3000", number.local_number

      number = context.parse("+852 2699 2838")
      assert_equal "2699 2838", number.local_number
    end
  end
end
