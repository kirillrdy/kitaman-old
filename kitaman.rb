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

  def run
    for kita_object in @queue

      kita_object.download_files if (kita_object.files_not_downloaded? or (@options[:force] and @options[:download]) )
  
      kita_object.build  if @options[:build]
      kita_object.install  if (not kita_object.installed? or (@options[:force] and @options[:install]))
     
    end
  end

  def load_needed_module(file)
    load 'kitaman/'+IO.read(Kita.find_kita_file(file)).scan(/KITA_TYPE="(.*?)"/)[0][0]+'.rb'
  end

  def parse_argv
    OptionParser.new do |opts|
      opts.banner = """Kitaman version:#{Kitaman.version}
      
Usage: kitaman.rb [options] packages"""

      opts.on("-f", "--force", "Force things") do |v|
        @options[:force] = v
      end
    
      opts.on("-d", "--download", "Force things") do |v|
        @options[:build] = false
        @options[:install] = false
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @options[:verbose] = v
      end
      opts.on("-t", "--[no-]test", "test build") do |v|
        @options[:install] = false
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
