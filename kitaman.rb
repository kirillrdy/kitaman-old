#!/usr/bin/ruby
###################################################
## Kitaman - Software Package Manager
## /-Promise to a little girl and a big world-/
##
## written by Kirill Radzikhovskyy
## kirillrdy@silverpond.com.au
###################################################

class Object
  def in(cmp)
    cmp.include? self
  end
end

class Kitaman
  
  def Kitaman.version
    "0.0.1"
  end

  def initialize
    @options = {'download' => true,'build' => true,'install' => true,'deep' => false,'deepest' => false,'force' => false,'search' => false,'remove' => false}
    @queue = []
  end

  def run
    @queue.reverse!
    for kita_object in @queue
      puts kita_object.inspect
    end
  end

  def build_queue(target)
    
    kita_instance = Kita.new(Kita.find_kita_file(target))  
    
    @queue << kita_instance if not kita_instance.in @queue

    for dependency in kita_instance.info["DEPEND"] 
      build_queue(dependency)
    end
  end

end

#############################################################
# Entry Point
#############################################################

require 'lib/kita_class'


kita = Kitaman.new

kita.build_queue("pariah-base")
kita.run
