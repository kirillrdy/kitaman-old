#!/usr/bin/ruby
###################################################
## Kitaman - Software Package Manager
## /-Promise to a little girl and a big world-/
##
## written by Kirill Radzikhovskyy
## kirillrdy@silverpond.com.au
###################################################

class Kitaman
  
  def Kitaman.version
    "0.0.1"
  end

  def initialize
    @options = {'download' => true,'build' => true,'install' => true,'deep' => false,'deepest' => false,'force' => false,'search' => false,'remove' => false}
    @queue = []
  end

  def run
    for kita_object in @queue
      puts kita_object
    end
  end

  def build_queue(target,list=[])
    
    kita_instance = Kita.new(Kita.find_kita_file(target))  
    list << kita_instance

    for 
    build_queue()
  
  end

end

#############################################################
# Entry Point
#############################################################

require 'lib/kita_class'

puts Kita.find_kita_file 'gcc'
