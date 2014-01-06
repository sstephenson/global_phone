require 'global_phone/context'

module GlobalPhone
  VERSION = '1.0.2'

  class Error < ::StandardError; end
  class NoDatabaseError < Error; end

  extend Context
end
