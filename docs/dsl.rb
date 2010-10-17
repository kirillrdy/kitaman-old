# Its time we write and documetn our new awesome dsl

# possible options :for => [:ubuntu, :pre_kita, :kita] # :kita is default

package 'ruby' ,:for => :ubuntu do
  name 'overwrite_package_name'
  version 'same'
  type :make # :make,:meta, :gnome, :xorg
  source ''
  patches []
  patch ''
  
  dependencies []
  depends_on ''
  depends ''
  
end
