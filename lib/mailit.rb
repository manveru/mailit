$LOAD_PATH.unshift(File.dirname(__FILE__))

module Mailit
  VERSION = '2009.03.10'
end

require 'mailit/mime'
require 'mailit/mail'
require 'mailit/mailer'
