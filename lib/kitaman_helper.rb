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


require 'kitaman/kita_helper'
require 'open-uri'

class Object
  def in(cmp)
    cmp.include? self
  end 
end


def update_src_files_database
  files_dictionary = {}
  for repo in IO.read(KitamanConfig.config['REPOST_LIST_FILE']).split("\n")
    puts "Syncing #{repo.blue}"
    list_of_files = open(repo).read.scan(/<a href=\"(.*?\.tar\.bz2)">(?:.*?)<\/a>/)  
    
    for file in list_of_files
      file = file[0]
      files_dictionary[file.smart_basename] = repo+file
    end

  end

  File.open('/var/kitaman/src.db','w') { |file|
    file.write(Marshal.dump(files_dictionary))
  }

end

def kita_error(string)
  puts string.bold.red
  exit 1
end

# This is pretty waistful, please FIXME
class KitamanConfig
  
  def KitamanConfig.config
    infos = IO.read('/etc/kitaman.conf').scan(/(.*?)="(.*?)"\n/)
    result = {}
    for info in infos
      result[info[0]]=info[1]
    end
    return result
  end

end

STYLE = {
      :default    =>    "\033[0m",
       # styles
       :bold       =>    "\033[1m",
       :underline  =>    "\033[4m",
       :blink      =>    "\033[5m",
       :reverse    =>    "\033[7m",
       :concealed  =>    "\033[8m",
      # font colors
       :black      =>    "\033[30m",
       :red        =>    "\033[31m",
       :green      =>    "\033[32m",
       :yellow     =>    "\033[33m",
       :blue       =>    "\033[34m",
       :magenta    =>    "\033[35m",
       :cyan       =>    "\033[36m",
       :white      =>    "\033[37m",
       # background colors
       :on_black   =>    "\033[40m",
       :on_red     =>    "\033[41m",
       :on_green   =>    "\033[42m",
       :on_yellow  =>    "\033[43m",
       :on_blue    =>    "\033[44m",
       :on_magenta =>    "\033[45m",
       :on_cyan    =>    "\033[46m",
       :on_white   =>    "\033[47m" }

class String

  def method_missing(st)
    "#{STYLE[st.to_sym]}#{self.to_s}#{STYLE[:default]}"  
  end  
  
end


def set_terminal_title(title)
  puts "\033]0;#{title}\007"
end

class GraphvizGraph
  def initialize
    @header = '''/* Generated by Kitaman. */
  digraph unix {
	size="600,600";
	node [color=lightblue2, style=filled];'''
    @list = []
  end
  
  def add(parent,child)
    if not [parent,child].in @list
      @list << [parent,child]
    end
  end

  def to_dot
   output = @header 
   for item in @list
    output +=  "\"#{item[0]}\" -> \"#{item[1]}\" ; \n"
   end
   output += "}"
   return output
  end
end

class Kitaman
  def parse_argv
      OptionParser.new do |opts|
        opts.banner = """Kitaman version:#{Kitaman.version.bold.red}
        
  Usage: kitaman.rb [options] packages"""

        opts.on("-f", "--force", "Force any action") do |v|
          @options[:force] = v
        end
      
        opts.on("-D", "--deep", "Deep Dependency Calculation") do |v|
          @options[:deep] = v
        end
      
        opts.on("-d", "--download", "Download Only") do |v|
          @options[:build] = false
          @options[:install] = false
          @options[:force] = false
        end

        opts.on("-b", "--build", "Build Only, doesnt install packages") do |v|
          @options[:install] = false
        end
        
        opts.on("-r", "--remove", "Remove the package") do |v|
          @options[:remove] = true
        end
      
        opts.on("-p", "--[no-]pretend", "Pretend") do |v|
          @options[:build] = false
          @options[:install] = false
          @options[:download] = false
        end

        opts.on("-q", "--[no-]quiet", "No questions asked") do |v|
          @options[:quiet] = v
        end
    
        opts.on("-v", "--[no-]verbose", "Run verbosely (Default)") do |v|
          @options[:verbose] = v
        end
        
        opts.on("--graph", "Generate DOT graph (FIXME) ") do |v|
          @options[:graph] = true
          @options[:quiet] = true
        end

        opts.on("--log", "Generate Actions log with results") do |v|
          @options[:save_log]= true
        end
      
        opts.on("-B",'--rebuild-one',"Force rebuild only one package") do |v|
          @options[:force] = true
          @options[:rebuild] = true
          @options[:deep] = true
        end

        opts.on("-S", "--[no-]sync", "sync") do |v|
          update_src_files_database
          exit
        end
      end.parse!
    end
end
