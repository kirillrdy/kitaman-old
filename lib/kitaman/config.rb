module Kitaman
  class Config
    PREFIX=File.dirname(__FILE__)+'/../..'

    GLOBAL_PREFIX='/var/kitaman'

    SRC_DIR="#{GLOBAL_PREFIX}/workdir/src"
    STATE_DIR="#{GLOBAL_PREFIX}/workdir/state"
    BUILD_DIR="#{GLOBAL_PREFIX}/workdir/build"
    PKG_DIR="#{GLOBAL_PREFIX}/workdir/pkg"
    TEMP_DIR="/var/tmp"

    # TODO this should be called repo
    SOURCES_LIST_LOCATION = "#{PREFIX}/conf/sources.list"

    REPOSITORIES_BASE_PATH = "#{GLOBAL_PREFIX}/repositories"

    SRC_MARSHAL_FILE="#{GLOBAL_PREFIX}/workdir/src.db"

    def self.init
      Shell.execute "mkdir -p #{SRC_DIR}"
      Shell.execute "mkdir -p #{STATE_DIR}"
      Shell.execute "mkdir -p #{BUILD_DIR}"
      Shell.execute "mkdir -p #{PKG_DIR}"
      Shell.execute "mkdir -p #{REPOSITORIES_BASE_PATH}"
    end
    
  end
end
