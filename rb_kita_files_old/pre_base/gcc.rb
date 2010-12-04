extend Make
extend PreBaby

@files = ["http://ftp.gnu.org/gnu/gcc/gcc-4.5.0/gcc-4.5.0.tar.bz2",
          "http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.bz2",
          "http://ftp.gnu.org/gnu/gmp/gmp-5.0.1.tar.bz2",
          "http://www.multiprecision.org/mpc/download/mpc-0.8.2.tar.gz"]


def config
  <<-EOF

    mv -v ../mpfr-2.4.2 mpfr
    mv -v ../gmp-5.0.1 gmp
    mv -v ../mpc-0.8.2 mpc

    mkdir -vp ../gcc-build
    cd ../gcc-build
    
    
    
    ../gcc-4.5.0/configure \
    --target=$LFS_TGT --prefix=/tools \
    --disable-nls --disable-shared --disable-multilib \
    --disable-decimal-float --disable-threads \
    --disable-libmudflap --disable-libssp \
    --disable-libgomp --enable-languages=c

  EOF
end


