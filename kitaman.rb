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
    "0.95.1"
  end

  def initialize
    @options = {:download => true,:build => true,:install => true,:deep => false,:deepest => false,:force => false,:search => false,:remove => false}
    @queue = []
  end

  def execute_action(kita_object,action)
    name_version  = kita_object.info["NAME-VER"]
    puts "Starting to #{action} #{name_version} ... ".style :green
    if !kita_object.send("#{action}ed?".to_sym) or (@options[:force] and @options[action])
      if not kita_object.send(action.to_sym)
          puts "Panic While Trying to #{action} for #{name_version}".style(:red).style(:bold)
        exit
      end
    else
      puts "No need to #{action} #{name_version}".style(:yellow).style :bold
    end
   puts "Finished #{action} #{name_version}".style(:red).style :bold
   puts "\n"
  end

  def run
    for kita_object in @queue
      set_terminal_title("x of x: #{kita_object.info["NAME-VER"]}")
      execute_action(kita_object,:download)
      execute_action(kita_object,:build)
      execute_action(kita_object,:install)
      set_terminal_title("Finished #{kita_object.info["NAME-VER"]}")      
    end
  end

  def load_needed_module(file)
    load 'kitaman/'+IO.read(Kita.find_kita_file(file)).scan(/KITA_TYPE="(.*?)"/)[0][0]+'.rb'
  end

  def parse_argv
    OptionParser.new do |opts|
      opts.banner = """Kitaman version:#{Kitaman.version.style(:bold).style(:red)}
      
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
  
      opts.on("-q", "--[no-]quiet", "No questions asked") do |v|
        @options[:quiet] = v
      end
  
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @options[:verbose] = v
      end

    end.parse!
  end

  def print_queue
    
    return false if @options[:quiet]
    puts "Kitaman will do the following: \n\n".style(:bold)
    for item in @queue
      flags = "[#{@options[:download] ? "D" : ""}#{@options[:build] ? "B" : ""}#{@options[:install] ? "I" : ""}]".style(:blue)
      puts "#{flags} "+item.info['NAME'].style(:cyan).style(:bold)+'-'+item.info['VER'].style(:bold).style(:green)
    end
    
    puts ""
    puts "Press Enter to continue...".style(:on_yellow).style(:bold)
    $stdin.gets
    
  end

 def build_queue(target)
   
    load_needed_module(target)
    kita_instance = Kita.new(Kita.find_kita_file(target))  
    
    if kita_instance.in @queue
      @queue.delete kita_instance
    end

    if not kita_instance.installed?
      @queue.insert(0,kita_instance)
    else
      return
    end

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
kita.run
