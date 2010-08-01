#!/usr/bin/env ruby


#    Kitaman - Software Package Manager
#    /-Promise to a little girl and a big world-/
#
#    Copyright (C) 2010  Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
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


RUBY_PREFIX=`which ruby`.gsub("/bin/ruby\n","")

require "/etc/kitaman_conf.rb"
require 'optparse'
require 'kitaman/kita_helper'
require 'kitaman/kitaman_helper'
require 'kitaman/kita'


class Kitaman
  
  def Kitaman.version
    "0.1.0"
  end

  def initialize
    @options = {:download   => true,
                :build      => true,
                :install    => true,
                :deep       => false,
                :deepest    => false,
                :force      => false,
                :search     => false,
                :remove     => false }

    # Results log for all actions
    @results_log = []
    
  end

  # TODO our temporary install methods
  # in future will handle removing packages as well
  def digest(kita_instance)
    kita_instance.call(:install)
  end

  # TODO legacy leftovers
  def show_actions_to_be_taken
   
    if not @target_list.hasChildren?
      puts "Nothing to do ...".bold.green
      exit
    end

    return false if (@options[:quiet])

    puts "\nKitaman will do the following: \n".bold

    @visit_list={}
    for target in @target_list.children
      traverse_tree_for_print target
    end

    puts "Number of Packages to be installed: " + @visit_list.keys.length.to_s.bold.cyan

    puts "\nPress Enter to continue...".on_yellow.bold
    $stdin.gets

  end

  def show_results_log
    puts ("#" * 50).bold
    puts "Kitaman Results Log:\n".blue
    total_failed = @results_log.select {|item| item[1]==false }
    
    for item in total_failed
      puts "Failed #{item[0]} ".red.bold
    end 

    puts "\nTotal failed actions: #{total_failed.length.to_s.red.bold}"
    puts "Total actions: #{@results_log.length.to_s.cyan}"
  
    if @options[:save_log]
      file = File.open('/var/kitaman/kitaman.log','w')
      for action in @results_log
        file.write("#{action[0]}:#{action[1]}\n")
      end
      file.close
    end
    
  end
    
end

#############################################################
# Entry Point
#############################################################


kitaman = Kitaman.new
kitaman.parse_argv

for argument in ARGV
  kitaman.digest(Kita.new(argument))
end


kitaman.show_results_log
