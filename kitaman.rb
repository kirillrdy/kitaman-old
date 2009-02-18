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

require 'tree'


class Kitaman
  
  attr_reader :queue
  attr_reader :root_node
  attr_reader :kita_hash
  

  def Kitaman.version
    "0.95.7alpha"
  end

  def initialize
    @options = {:download => true,:build => true,:install => true,:deep => false,:deepest => false,:force => false,:search => false,:remove => false}
    @queue = []
    @root_node = nil
    @node_hash = {}
    @kita_hash = {}
    
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


  def traverse_tree_for_print(node = self.root_node)

    if node.hasChildren?
      for child in node.children        
        traverse_tree_for_print child
      end      
    end  
    puts node.content.info['NAME'].blue+'-'+node.content.info['VER'].bold.green
  end
  
  def show_actions_to_be_taken
   
    return false if (@options[:quiet]) 
    if @options[:graph]
      puts @graphviz_graph.to_dot
      return
    end
    puts "\nKitaman will do the following: \n".bold
  
    traverse_tree_for_print
    
    puts "Number of Packages to be installed: " + @root_node.size.to_s.bold.cyan
    
    puts ""
    puts "Press Enter to continue...".on_yellow.bold
    $stdin.gets
    
  end
  
  def get_kita_instance(kita)
    @kita_hash[kita] || Kita.new(Kita.find_kita_file(kita)) 
  end

  def build_queue(target, parent = nil)
    
    kita_instance = get_kita_instance(target)
      
    if not @node_hash[target] and not kita_instance.installed?
      
      node_to_be_inserted = Tree::TreeNode.new(target,kita_instance)
            
      if parent
        @node_hash[parent] << node_to_be_inserted
      else
        node_to_be_inserted << @root_node if @root_node
        @root_node = node_to_be_inserted
      end
      
      #register in hash
      @node_hash[target] = node_to_be_inserted
              
      for dependency in kita_instance.info["DEPEND"]
          build_queue(dependency,target)
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

kitaman.show_actions_to_be_taken
#kitaman.traverse_tree_for_print
#kitaman.run
