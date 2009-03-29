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
  
  attr_reader :root_node
  attr_reader :kita_hash  

  def Kitaman.version
    "0.98.0"
  end

  def initialize
    @options = {:download => true,:build => true,:install => true,:deep => false,:deepest => false,:force => false,:search => false,:remove => false}

    @root_node = nil
    
    # hash for tree insertion
    @node_hash = {}
    
    # hash for loaded kita instances
    @kita_hash = {}
    @results_log = []
    
    #fix this
    @graphviz_graph = GraphvizGraph.new
  end

  def run(node = self.root_node)
    result = true
  
    if node.hasChildren?
      for child in node.children
        temp_result = run(child)
        result = (result and temp_result)
     end      
    end    

    # if one of children failed, we do not need to run us 
    return false if not result

    load_needed_module(node.content.info['NAME'])
    
    # FIXME, it needs to say 1 of N: packagename-ver
    set_terminal_title(node.content.info["NAME-VER"])
    
    actions = [:download,:build,:install]
    
    for action in actions      
      # as soon as one of actions fail, we fail
      return false if not execute_action(node.content,action)
    end
    
    # everything is working !
    set_terminal_title("Finished #{node.content.info["NAME-VER"]}")
    return true
  end

   
  def show_actions_to_be_taken
   
   if not @root_node
      puts "Nothing to do ...".bold.green
      exit
    end
   
    return false if (@options[:quiet])  
    
    
    puts "\nKitaman will do the following: \n".bold
  
    traverse_tree_for_print
    
    puts "Number of Packages to be installed: " + @root_node.size.to_s.bold.cyan
    
    puts ""
    puts "Press Enter to continue...".on_yellow.bold
    $stdin.gets
    
  end
  
  def show_results_log    
    puts "################################################################################".bold
    puts "Kitaman Results Log:\n".blue
    total_failed = @results_log.select {|item| item[1]==false }
    for item in total_failed
      puts "Failed #{item[0]} ".red.bold
    end 

    puts "\nTotal failed actions: #{total_failed.length.to_s.red.bold}"
    puts "Total actions: #{@results_log.length.to_s.cyan}"
  
    if @options[:save_log]
      file = File.open('/kitaman.log','w')
      for action in @results_log
        file.write("#{action[0]},#{action[1]}\n")
      end
      file.close
    end
    
  end
 
  def build_queue(target, parent = nil)

    kita_instance = get_kita_instance(target)

    load_needed_module(kita_instance.info['NAME'])
      
    if not @node_hash[target] and (not kita_instance.installed? or @options[:deep])      

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
  
  private
  
   def get_kita_instance(kita)
    if not @kita_hash[kita]
      @kita_hash[kita] = Kita.new(Kita.find_kita_file(kita))
    end
    return @kita_hash[kita]
  end
  
   def traverse_tree_for_print(node = self.root_node)
 
    if node.hasChildren?
      for child in node.children        
        traverse_tree_for_print child
      end      
    end  
    puts node.content.info['NAME'].blue+'-'+node.content.info['VER'].bold.green
  end
  
   def execute_action(kita_object,action)
    name_version  = kita_object.info["NAME-VER"]
    if (!kita_object.send("#{action}ed?".to_sym) and @options[action]) or (@options[:force] and @options[action])
      puts "Starting to #{action} #{name_version} ... ".green
      if not kita_object.send(action.to_sym)
        @results_log << ["#{name_version}:#{action}",false]
        return false
      else
        puts "Finished #{action}ing #{name_version}".blue.bold
        @results_log << ["#{name_version}:#{action}",true]
      end      
    else
      puts "No need to #{action} #{name_version}".yellow.bold
      @results_log << ["#{name_version}:#{action}",nil]
    end
    return true
  end
  
   def load_needed_module(file)
    
    if not Kita.find_kita_file(file)
      kita_error "no kita file found for #{file}"      
    end
    scanned_file = IO.read(Kita.find_kita_file(file)).scan(/KITA_TYPE="(.*?)"/)
    if not scanned_file[0] or not load('kitaman/'+ scanned_file[0][0]+'.rb')
      kita_error "No MODULE found for #{Kita.find_kita_file(file)}"
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

kitaman.run
kitaman.show_results_log
