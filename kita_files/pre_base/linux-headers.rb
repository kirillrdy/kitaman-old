extend Make

@files = "http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.34.tar.bz2"

def config
  return
end

def build
  "
  make mrproper
  make headers_check
  "
end

def kita_install
  "
  make INSTALL_HDR_PATH=dest headers_install
  mkdir -pv $INSTALL_DIR/tools/include
  cp -rv dest/include/* $INSTALL_DIR/tools/include
  "
end
