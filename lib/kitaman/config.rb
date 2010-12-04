module Kitaman
  class Config
    PREFIX=File.dirname(__FILE__)+'/../..'

    #KITA_FILES_DIR="#{KITAMAN_PREFIX}/kita_files"

    SRC_DIR="#{KITAMAN_PREFIX}/workdir/src"
    STATE_DIR="#{KITAMAN_PREFIX}/workdir/state"
    BUILD_DIR="#{KITAMAN_PREFIX}/workdir/build"
    PKG_DIR="#{KITAMAN_PREFIX}/workdir/pkg"
    FAKE_INSTALL_DIR="#{KITAMAN_PREFIX}/workdir/install"
    TEMP_DIR="/var/tmp"
    
    REPOS_LIST_FILE="#{KITAMAN_PREFIX}/conf/kitaman.repos"
    SRC_MARSHAL_FILE="#{KITAMAN_PREFIX}/workdir/src.db"
  end
end
