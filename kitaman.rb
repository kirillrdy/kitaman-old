#!/usr/bin/ruby
###################################################
## Kitaman - Software Package Manager
## /-Promise to a little girl and a big world-/
##
## written by Kirill Radzikhovskyy
## kirillrdy@silverpond.com.au
###################################################

require 'lib/kitaman_helper'
require 'lib/kita_class'

class Kitaman
  
  attr_reader :queue

  def Kitaman.version
    "0.0.1"
  end

  def initialize
    @options = {'download' => true,'build' => true,'install' => true,'deep' => false,'deepest' => false,'force' => false,'search' => false,'remove' => false}
    @queue = []
  end

  def run
    for kita_object in @queue
      puts kita_object.inspect
        
      if @options['download']
        kita_object.download_files
      end
    end
  end

  def build_queue(target)
    
    kita_instance = Kita.new(Kita.find_kita_file(target))  
    
    if kita_instance.in @queue
      @queue.delete kita_instance
    end
    @queue.insert(0,kita_instance)

    for dependency in kita_instance.info["DEPEND"] 
      build_queue(dependency)
    end
  end

end

#############################################################
# Entry Point
#############################################################


kita = Kitaman.new

kita.build_queue("gcc")
kita.build_queue("pariah-base")
kita.build_queue("gcc")
puts kita.inspect
