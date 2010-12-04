package 'vim' do
  type 'Make'
  source "ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2"

  def config
  "
    echo '#define SYS_VIMRC_FILE \"/etc/vimrc\"' >> src/feature.h
    ./configure --prefix=/usr --enable-multibyte
  "
  end


  def build
  '
    make

    mkdir -p $INSTALL_DIR/etc
    #some basic config
    cat > $INSTALL_DIR/etc/vimrc << "EOF"
    " Begin /etc/vimrc
    " This vimrc was written by Kirill R

    set nocompatible
    set backspace=2
    set ai
    set ruler

    " set shiftwidth=2 for a good reason
    set shiftwidth=2

    set expandtab
    set tabstop=2

    set mousemodel=popup          " right mouse button pops up a menu in the GUI


    syntax on
    set hlsearch
    if (&term == "iterm") || (&term == "putty")
      set background=dark
    endif

    " End /etc/vimrc
  EOF
  '
  end


end
