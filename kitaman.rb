#!/usr/bin/ruby
###################################################
## Kitaman - Software Package Manager
## /-Promise to a little girl and a big world-/
##
## written by Kirill Radzikhovskyy
## kirillrdy@silverpond.com.au
###################################################

require 'optparse'
require 'kitaman/kitaman_helper'
require 'kitaman/kita_class'

class Kitaman
  
  attr_reader :queue

  def Kitaman.version
    "0.0.1"
  end

  def initialize
    @options = {:download => true,:build => true,:install => true,:deep => false,:deepest => false,:force => false,:search => false,:remove => false}
    @queue = []
  end

  def execute_action(kita_object,action)
    if kita_object.send("not_#{action}ed?".to_sym) or (@options[:force] and @options[action])
      if not kita_object.send(action.to_sym)
          puts "Panic While Trying to #{action} for #{kita_object.info["NAME-VER"]}"
        exit
      end
    end
  end

  def run
    for kita_object in @queue
      execute_action(kita_object,:download) 
      execute_action(kita_object,:build) 
      execute_action(kita_object,:install) 
    end
  end

  def load_needed_module(file)
    load 'kitaman/'+IO.read(Kita.find_kita_file(file)).scan(/KITA_TYPE="(.*?)"/)[0][0]+'.rb'
  end

  def parse_argv
    OptionParser.new do |opts|
      opts.banner = """Kitaman version:#{Kitaman.version}
      
Usage: kitaman.rb [options] packages"""

      opts.on("-f", "--force", "Force any action") do |v|
        @options[:force] = v
      end
    
      opts.on("-d", "--download", "Download Only") do |v|
        @options[:build] = false
        @options[:install] = false
      end

      opts.on("-b", "--build", "Build Only") do |v|
        @options[:install] = false
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @options[:verbose] = v
      end

    end.parse!
  end

  def print_queue
    for item in @queue
      puts 'I '+item.info['NAME']+'-'+item.info['VER']
    end
  end

 def build_queue(target)
   
    load_needed_module(target)
    kita_instance = Kita.new(Kita.find_kita_file(target))  
    
    if kita_instance.in @queue
      @queue.delete kita_instance
    end
    @queue.insert(0,kita_instance)

    for dependency in kita_instance.info["DEPEND"].reverse
      build_queue(dependency)
    end
  end

end

#############################################################
# Entry Point
#############################################################


kita = Kitaman.new
kita.parse_argv
for argument in ARGV
  kita.build_queue(argument)
end
kita.print_queue

puts "Press Enter to continue..."
$stdin.gets

kita.run
