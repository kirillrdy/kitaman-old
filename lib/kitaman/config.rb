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
    
    REPOS_LIST_FILE="#{PREFIX}/conf/kitaman.repos"
    SRC_MARSHAL_FILE="#{PREFIX}/workdir/src.db"
  end
end
