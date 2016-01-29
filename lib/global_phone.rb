require 'global_phone/utils'
require 'global_phone/context'

module GlobalPhone
  VERSION = '1.0.1'

  class Error < ::StandardError; end
  class NoDatabaseError < Error; end

  extend Context
end
