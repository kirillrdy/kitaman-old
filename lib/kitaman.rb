require 'optparse'
require 'open-uri'

module Kitaman
end

require_relative 'kitaman/argument_parser'
require_relative 'kitaman/package'





# TODO figure out where is the best place for those
#`mkdir -p #{KITAMAN_SRC_DIR}`
#`mkdir -p #{KITAMAN_STATE_DIR}`
#`mkdir -p #{KITAMAN_BUILD_DIR}`
#`mkdir -p #{KITAMAN_FAKE_INSTALL_DIR}`
#`mkdir -p #{KITAMAN_PKG_DIR}`


# Require all the modules
require_relative 'kitaman/package_modules/make'
require_relative 'kitaman/package_modules/meta'

