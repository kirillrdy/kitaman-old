#Basics Package attributes
@name = 'package_name'
@version = '0.1'
@type = :make
@dependencies = []
@post_install_cmd = ''


# make related attributes
@sources = []
@patches = []
@prefix = '/usr'
@pre_configure_cmd = ''
@configure_cmd = "./configure --prefix=#{@prefix}"
@additional_configure = ''
@build_cmd = 'make'
@install_cmd = 'make install'

# Its time to write documentation for our awesome dsl
package 'ruby' do

  # Basics
  version '1.9.2' # overwrite auto detection
  type :make # :make,:meta, :gnome, :xorg

  # Dependency managment
  dependency ''
  dependencies []
  depends '' || []
  depends_on '' || []

  # post_install
  post_install do
    'echo "Post Install ... blank "'
  end

  # Source locations
  source ''
  sources ['','']

  # Patches
  patches ['','']
  patch ''

  # make related
  prefix '/stuff'
  
  pre_configure do
    ''
  end
  configure do
    './configure --prefix=/usr'
  end
  additional_configure do
    ''
  end

  build do
    'make'
  end

  install do
    'make install'
  end

end
