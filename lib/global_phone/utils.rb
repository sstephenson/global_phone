module GlobalPhone
  module Utils
    extend self

    def map_detect(collection)
      collection.each do |value|
        if result = yield(value)
          return result
        end
      end
    end
  end
end
