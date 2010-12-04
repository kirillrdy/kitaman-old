extend Make
extend PreBaby


@files="http://ftp.gnu.org/gnu/binutils/binutils-2.20.1.tar.bz2"



@build_dir = "#{KITAMAN_BUILD_DIR}/binutils-2.20.1"
def config
  <<-EOF
    mkdir -pv ../binutils-build
    cd ../binutils-build
   ../binutils-2.20.1/configure \
    --target=$LFS_TGT --prefix=/tools \
    --disable-nls --disable-werror
  EOF
end


def kita_install_OLD
  <<-EOF
    mkdir -p $INSTALL_DIR
    make DESTDIR=$INSTALL_DIR tooldir=/usr install
  EOF
end
