# Its time we write and documentatio for our new awesome dsl
package 'ruby' do

  # Basics
  version '1.9.2' # overwrite auto detection
  type :make # :make,:meta, :gnome, :xorg

  # Source locations
  source ''
  sources ['','']

  # Patches
  patches ['','']
  patch ''

  # Dependency managment
  dependency ''
  dependencies []
  depends '' || []
  depends_on '' || []


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

  # post_install
  post_install do
    'echo "Post Install ... blank "'
  end

end
