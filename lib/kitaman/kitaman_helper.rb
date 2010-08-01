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


require 'open-uri'


# Standart way for Kitaman to notify user of an error
def kita_error(string)
  puts "KITAMAN ERROR: #{string}".bold.red
  exit 1
end

def execute_command(command)
  result = system(command)
  if not result
    puts command
    exit 1
  end
  return result
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
    return "#{STYLE[st.to_sym]}#{self.to_s}#{STYLE[:default]}" if STYLE[st.to_sym]
    super st
  end
end


def set_terminal_title(title)
  puts "\033]0;#{title}\007"
end


class Kitaman

  def self.update_src_files_database
    files_dictionary = {}
    for repo in IO.read(KITAMAN_REPOS_LIST_FILE).split("\n")
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

  # Helper used to download singe file
  def self.download_one_file(file)
    result = true
    
    if File.exists?("#{KITAMAN_SRC_DIR}/#{File.basename(file)}")
      execute_command("mv #{KITAMAN_SRC_DIR}/#{File.basename(file)} #{KITAMAN_TEMP_DIR}/")
    end

    result = (result and execute_command("wget -c #{file} -O #{KITAMAN_TEMP_DIR}/#{File.basename(file)}"))
    result = (result and execute_command("mv #{KITAMAN_TEMP_DIR}/#{File.basename(file)} #{KITAMAN_SRC_DIR}/"))
    return result
  end

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
        end

        opts.on("-S", "--[no-]sync", "sync") do |v|
          Kitaman.update_src_files_database
          exit
        end
      end.parse!
    end
end