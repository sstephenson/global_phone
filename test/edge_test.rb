require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class EdgeTest < TestCase
    test "formatting numbers that match a pattern but not leading digits" do
      # Because of the way we build our database, some numbers
      # will match a format pattern but not its leading digits
      # regex. Instead of requiring a number's format to match
      # both the format pattern and leading digits, we will
      # prefer the format whose leading digits match, if possible,
      # or fall back to the first pattern-matched format.

      # In this case, 1520123456 matches one of Ireland's "premium
      # rate" format specifications in PhoneNumberMetaData.xml.
      # We don't include those formats in our database, so we fall
      # back to the closest match.
      number = context.parse("1520123456", "IE")
      assert_equal "1520 123 456", number.national_format
    end
  end
end
