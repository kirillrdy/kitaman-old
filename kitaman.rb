#!/usr/bin/ruby


#    Kitaman - Software Project Manager
#    /-Promise to a little girl and a big world-/
#
#    Copyright (C) 2009  Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


require 'optparse'
require 'kitaman/kitaman_helper'
require 'kitaman/kita_class'


class Kitaman
  
  attr_reader :queue

  def Kitaman.version
    "0.95.6"
  end

  def initialize
    @options = {:download => true,:build => true,:install => true,:deep => false,:deepest => false,:force => false,:search => false,:remove => false}
    @queue = []
    
    #fix this
    @graphviz_graph = GraphvizGraph.new
  end

  def execute_action(kita_object,action)
    name_version  = kita_object.info["NAME-VER"]
    if (!kita_object.send("#{action}ed?".to_sym) and @options[action]) or (@options[:force] and @options[action])
      puts "Starting to #{action} #{name_version} ... ".green
      if not kita_object.send(action.to_sym)
        puts "Panic While Trying to #{action} #{name_version}".red.bold
        exit
      end
      puts "Finished #{action}ing #{name_version}".blue.bold
      puts "\n"
    else
      puts "No need to #{action} #{name_version}".yellow.bold
    end

  end

  def run
    for kita_object in @queue
      load_needed_module(kita_object.info['NAME'])
      if @queue.length==1
        set_terminal_title(kita_object.info["NAME-VER"])
      else
        set_terminal_title("#{@queue.index(kita_object).to_i + 1} of #{@queue.length}: #{kita_object.info["NAME-VER"]}")
      end
      execute_action(kita_object,:download)
      execute_action(kita_object,:build)
      execute_action(kita_object,:install)
      set_terminal_title("Finished #{kita_object.info["NAME-VER"]}")      
    end
  end

  def load_needed_module(file)
    
    if not Kita.find_kita_file(file)
      puts  "no kita file found for #{file}"
      exit
    end
    scanned_file = IO.read(Kita.find_kita_file(file)).scan(/KITA_TYPE="(.*?)"/)
    if not scanned_file[0] or not load('kitaman/'+ scanned_file[0][0]+'.rb')
      puts "No MODULE found for #{Kita.find_kita_file(file)}".red.bold
      exit
    end
  end

  def parse_argv
    OptionParser.new do |opts|
      opts.banner = """Kitaman version:#{Kitaman.version.bold.red}
      
Usage: kitaman.rb [options] packages"""

      opts.on("-f", "--force", "Force any action") do |v|
        @options[:force] = v
      end
    
      opts.on("-d", "--download", "Download Only") do |v|
        @options[:build] = false
        @options[:install] = false
        @options[:force] = false
      end

      opts.on("-b", "--build", "Build Only") do |v|
        @options[:install] = false
      end
 
      opts.on("-p", "--[no-]pretend", "Pretend") do |v|
        @options[:build] = false
        @options[:install] = false
        @options[:download] = false
      end

      opts.on("-q", "--[no-]quiet", "No questions asked") do |v|
        @options[:quiet] = v
      end
  
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @options[:verbose] = v
      end
      
      opts.on("-G", "--[no-]graph", "Generate DOT graph") do |v|
        @options[:graph] = v
      end

      opts.on("-S", "--[no-]sync", "sync") do |v|
        update_src_files_database
        exit
      end
    end.parse!
  end

  def print_queue
    
    return false if (@options[:quiet] or @queue.length==0 ) 
    if @options[:graph]
      puts @graphviz_graph.to_dot
      return
    end
    puts "\nKitaman will do the following: \n".bold
    for item in @queue
      flags = "[#{@options[:download] ? "D" : ""}#{@options[:build] ? "B" : ""}#{@options[:install] ? "I" : ""}]".blue
      puts "#{flags} "+item.info['NAME'].cyan.bold+'-'+item.info['VER'].bold.green
    end
    
    puts ""
    puts "Press Enter to continue...".on_yellow.bold
    $stdin.gets
    
  end

  def build_queue(target)
  
    #Object.send(:remove_const,:Kita)

    load_needed_module(target)
    kita_instance = Kita.new(Kita.find_kita_file(target))  
    
    if kita_instance.in @queue
      @queue.delete kita_instance
    end

    if not kita_instance.installed?
      @queue.insert(0,kita_instance)
      
      for dependency in kita_instance.info["DEPEND"].reverse
          print "."
          
          @graphviz_graph.add(kita_instance.info['NAME'],dependency) if @options[:graph]          
        
          build_queue(dependency)

      end

    end

    
  end


end

#############################################################
# Entry Point
#############################################################


kitaman = Kitaman.new
kitaman.parse_argv
for argument in ARGV
  kitaman.build_queue(argument)
end

kitaman.print_queue
kitaman.run
