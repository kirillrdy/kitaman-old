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



# Load all the modules availible
Dir["#{KITAMAN_PREFIX}/lib/ruby/#{RUBY_VERSION}/kitaman/modules/*"].each {|file| require file}

# Each Package is represented by Kita class
class Kita
  
  # Find kita file by package name
  def Kita.find_kita_file(package_name)
    found_files = Dir["#{KITA_FILES_DIR}/**/#{package_name}.rb"]
    kita_error "No kitafile found for \'#{package_name}\'" if found_files.length == 0

    if found_files.length > 1
      found_files.each_index {|x| puts  "[#{x}]: #{found_files[x]}" }
      choice = $stdin.gets
      found_files = [found_files[choice.to_i]]
    end
    return found_files.first
  end

  # String representation of kita instance
  # eg gnome-terminal-2.29.3
  def to_s
    [@name,@version].join "-"
  end
  
  # Creates Kita object and parses all the information
  def initialize(kita_name)
    
    @name = File.basename(kita_name,'.rb')
    @depend = []
    @patches = []
    
    # Load file and evaluate it
    instance_eval(IO.read(Kita.find_kita_file(kita_name)))
    
    
    @depend = @depend.split(" ") if @depend.is_a?(String)
    
    @files ||= get_files_from_repo
    @files = [@files] if @files.is_a?(String)
    @patches = [@patches] if @patches.is_a?(String)
    @version =  version

  end
   
   
  # THIS IS THE RECURSIVE THINGY TODO
  # by given action 
  # :install ,:remove
  def call(action)
  
    for dependency in @depend
      Kita.new(dependency).call(action)
    end
  
    if action == :install
      download unless downloaded?

      #TODO Clean
      puts "Installing #{self.to_s}".bold.green unless installed?
      install unless installed?
    end
    
    if action == :remove
      remove if installed?
    end
    
  end
   
   
  # Downloads all files in @files var, returns true if all files downloaded successfully
  def download
    success=true
    for file in files_list_to_download
      success = (success and Kitaman.download_one_file(file))
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
  
  

  # This is a default install action, modules should be implementing this
  # kept here for sentemental purposes
  def install
    puts "please write install instructions for this package"
  end

  # Checks if package is installed
  def installed?
    File.exist?(KITAMAN_STATE_DIR+'/'+self.to_s)
  end

  ##############################################################################
  private
  ##############################################################################

  # Returns a list of URLS of source files to be downloaded
  def files_list_to_download
    (@files + @patches)
  end
  
  # Returns a list of full paths to local source files belonging to package
  def files_list_local
    list= @files + @patches
    list.map {|x| KITAMAN_SRC_DIR+'/'+ File.basename(x) }
  end

  # Fills FILES var with files maching in repository
  def get_files_from_repo
       
    Kitaman.update_src_files_database if not File.exist?('/var/kitaman/src.db')
    
    @@files_list_database ||= Marshal.load(IO.read('/var/kitaman/src.db'))
    @@files_list_database[@name] ? [@@files_list_database[@name]] : []
  end

  # helper method used to set @version
  # It will find version of first file availible for package
  # or return undefined which is bad, and prob should be an exception
  def version
    @files.first ? @files.first.version : 'undefined'
  end

   # Create a state file meaning that package is installed
   # Please note this parent method creates empty files
   # Child modules overwrite this
   def record_installed
    `touch #{state_file}`
  end
  
 # Removes all files listed in state file, and removes the state file
 def remove
  for line in IO.read(KITAMAN_STATE_DIR+'/'+ self.to_s).lines.to_a.reverse
    puts line
  end
 end

  # Location of state file for kita
  def state_file
    KITAMAN_STATE_DIR+'/'+self.to_s
  end

end
