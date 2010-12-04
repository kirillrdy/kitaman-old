require 'optparse'
require 'open-uri'

# TODO figure why we need this
#require 'active_support/inflector'



# TODO figure out where is the best place for those
#`mkdir -p #{KITAMAN_SRC_DIR}`
#`mkdir -p #{KITAMAN_STATE_DIR}`
#`mkdir -p #{KITAMAN_BUILD_DIR}`
#`mkdir -p #{KITAMAN_FAKE_INSTALL_DIR}`
#`mkdir -p #{KITAMAN_PKG_DIR}`



require_relative 'kitaman/kita_helper'
require_relative 'kitaman/kitaman_helper'
require_relative 'kitaman/kita'

# Require all the modules
require_relative 'kitaman/modules/make'
require_relative 'kitaman/modules/meta'
