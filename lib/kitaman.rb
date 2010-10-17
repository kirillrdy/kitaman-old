require 'optparse'
require 'active_support/inflector'


KITAMAN_PREFIX=File.dirname(__FILE__)+'/..'

KITA_FILES_DIR="#{KITAMAN_PREFIX}/kita_files"

KITAMAN_SRC_DIR="#{KITAMAN_PREFIX}/workdir/src"
KITAMAN_STATE_DIR="#{KITAMAN_PREFIX}/workdir/state"
KITAMAN_BUILD_DIR="#{KITAMAN_PREFIX}/workdir/build"
KITAMAN_PKG_DIR="#{KITAMAN_PREFIX}/workdir/pkg"
KITAMAN_FAKE_INSTALL_DIR="#{KITAMAN_PREFIX}/workdir/install"
KITAMAN_TEMP_DIR="/var/tmp"

`mkdir -p #{KITAMAN_SRC_DIR}`
`mkdir -p #{KITAMAN_STATE_DIR}`
`mkdir -p #{KITAMAN_BUILD_DIR}`
`mkdir -p #{KITAMAN_FAKE_INSTALL_DIR}`
`mkdir -p #{KITAMAN_PKG_DIR}`



KITAMAN_REPOS_LIST_FILE="#{KITAMAN_PREFIX}/conf/kitaman.repos"
KITAMAN_SRC_MARSHAL_FILE="#{KITAMAN_PREFIX}/workdir/src.db"

require_relative 'kitaman/kita_helper'
require_relative 'kitaman/kitaman_helper'
require_relative 'kitaman/kita'

# Require all the modules
require_relative 'kitaman/modules/make'
require_relative 'kitaman/modules/meta'
