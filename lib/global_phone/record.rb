require 'forwardable'

module GlobalPhone
  class Record
    extend Forwardable

    def self.field(index, name, options = {}, &block)
      if block
        transform_method_name = :"transform_field_#{name}"
        define_method(transform_method_name, block)
      end

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          value = @data[#{index.inspect}]
          #{"value = #{transform_method_name}(value) if value" if block}
          value #{"|| #{options[:fallback]}" if options[:fallback]}
        end
      RUBY
    end

    def initialize(data)
      @data = data
    end
  end
end
