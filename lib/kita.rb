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
require 'kitaman/kitaman_helper'
require '/etc/kitaman_conf'

Dir["/usr/lib/ruby/#{RUBY_VERSION}/kitaman/modules/*"].each {|file| require file}

class Kita
  # Class that represents a package in Kitaman world
  
  # String representation of kita instance  
  def to_s
    @name + "-" + @version
  end
   
  # Find kita file by package name
  def Kita.find_kita_file(package_name)
    found_file = `find #{KITA_FILES_DIR} -type f -name "#{package_name}.rb"`.split("\n")
    if found_file.length == 0
      kita_error "No kitafile found for \'#{package_name}\'"
    elsif found_file.length > 1
      kita_error "More than one kita file is found for #{package_name}"
    else
      return found_file[0]
    end
        
  end
  
  # Creates Kita object and parses all the information
  def initialize(kita_name)
    
    instance_eval(IO.read(Kita.find_kita_file(kita_name)))
    
    @name     ||=   File.basename(kita_name,'.rb')
    @files    ||=   get_files_from_repo
    
    @files = [@files] if @files.is_a?(String)
    
    @patches  ||=   []
    
    @patches = [@patches] if @patches.is_a?(String)
    
    @version  ||=   get_version
    @depend   ||=   []
    
    @depend = @depend.split(" ") if @depend.is_a?(String)

  end
   
   
  # THIS IS THE RECURSIVE THINGY TODO
  def call(action)
  
    for dependency in @depend
      Kita.new(dependency).call(action)
    end
  
    if action == :install
      download unless downloaded?
      install unless installed?
    end
    
    if action == :remove
      remove if installed?
    end
    
  end
   
   
   
  # Downloads all files in FILES var, returns True if all files downloaded successfully
  def download
    success=true
    for file in files_list_to_download
      success = (success and download_one_file(file))
    end
    return success
  end

  # Checks if all files are downloaded
  def downloaded?
    results = true
    for file in files_list_local 
      results = (results and File.exists?(file))
    end
    return results
  end
  
  

  def install
    puts "please write install instructions for this package"
  end

  # Checks if package is installed
  def installed?
    File.exist?(KITAMAN_STATE_DIR+'/'+self.to_s)
  end

  # Things that none should see
  private

  # Returns a list of URLS of source files to be downloaded
  def files_list_to_download
    (@files + @patches)
  end
  
  # Helper used to download singe file
  def download_one_file(file)
    result = true
    
    if File.exists?("#{KITAMAN_SRC_DIR}/#{File.basename(file)}")
      system("mv #{KITAMAN_SRC_DIR}/#{File.basename(file)} #{KITAMAN_SRC_DIR}/")
    end

    result = (result and system("wget -c #{file} -O #{KITAMAN_TEMP_DIR}/#{File.basename(file)}"))
    result = (result and system("mv #{KITAMAN_TEMP_DIR}/#{File.basename(file)} #{KITAMAN_SRC_DIR}/"))
    return result
  end
  
  # Returns a list of full paths to local source files belonging to package
  def files_list_local
    list=[]
    for file in ( @files + @patches)
      list << (KITAMAN_SRC_DIR+'/'+File.basename(file))
    end
    list
  end

  # Fills FILES var with files maching in repository
  def get_files_from_repo
       
    update_src_files_database if not File.exist?('/var/kitaman/src.db')
    
    @@files_list_database ||= Marshal.load(IO.read('/var/kitaman/src.db'))
    @@files_list_database[@name] ? [@@files_list_database[@name]] : []
  end

  # Get version from source file
  def get_version
    if @files!=[]
      ver = @files[0].version
    else
      ver = "undefined"
    end
    return ver
  end

 # Create a state file meaning that package is installed
  def record_installed
    `touch #{state_file}`
  end
  
 # Removes all files listed in state file, and removes the state file
 def remove
  for line in IO.read(KITAMAN_STATE_DIR+'/'+self.to_s).lines.to_a.reverse
    puts line
  end
 end

##############################################################################
private
##############################################################################

  def state_file
    KITAMAN_STATE_DIR+'/'+self.to_s
  end

end
