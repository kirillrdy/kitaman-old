module Kitaman
  class Config
    PREFIX=File.dirname(__FILE__)+'/../..'

    #KITA_FILES_DIR="#{PREFIX}/kita_files"

    SRC_DIR="#{PREFIX}/workdir/src"
    STATE_DIR="#{PREFIX}/workdir/state"
    BUILD_DIR="#{PREFIX}/workdir/build"
    PKG_DIR="#{PREFIX}/workdir/pkg"
    FAKE_INSTALL_DIR="#{PREFIX}/workdir/install"
    TEMP_DIR="/var/tmp"
    
    # TODO this should be called repo
    SOURCES_LIST_LOCATION = "#{PREFIX}/conf/sources.list"
    
    REPOSITORIES_BASE_PATH = "#{PREFIX}/repositories"
    
    SRC_MARSHAL_FILE="#{PREFIX}/workdir/src.db"

    def self.init
      Shell.execute "mkdir -p #{SRC_DIR}"
      Shell.execute "mkdir -p #{STATE_DIR}"
      Shell.execute "mkdir -p #{BUILD_DIR}"
      Shell.execute "mkdir -p #{FAKE_INSTALL_DIR}"
      Shell.execute "mkdir -p #{PKG_DIR}"
      Shell.execute "mkdir -p #{REPOSITORIES_BASE_PATH}"
    end
    
  end
end
