module Kitaman

  require 'optparse'
  require 'open-uri'
  require 'logger'


  list_of_modules_to_load = ['argument_parser','package','file',
                             'shell','error','log','config',
                             'downloader','colours','computer',
                             'user','files_database','repository','dsl/make','dsl/meta','package_dsl']

  list_of_modules_to_load.each {|x| require_relative 'kitaman/'+ x }


  # Require all the modules
  require_relative 'kitaman/package/make'
  require_relative 'kitaman/package/meta'

end
