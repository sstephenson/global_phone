require File.expand_path('../test_helper', __FILE__)

module GlobalPhone
  class FormatTest < TestCase
    test 'non-matching leading digits' do
      assert_false format.match('1582380560', true)
    end

    def format
      # This is a GB format taken from the seed data.
      Format.new(["(\\d{2})(\\d{4})(\\d{4})",
                  "$1 $2 $3",
                  "2|5[56]|7(?:0|6[013-9])2|5[56]|7(?:0|6(?:[013-9]|2[0-35-9]))"])
    end
  end
end
