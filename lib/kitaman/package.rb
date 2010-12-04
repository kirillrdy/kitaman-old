module Kitaman
  class Package

    def self.all
      return @packages if @packages

      @packages ||= {}
      Dir[File.dirname(__FILE__) + '/../../packages/**/*.rb'].each do |x|
        Logger.write " >> trying to load #{File.basename(x)}"
        self.instance_eval(IO.read(x))
      end
      
      #TODO dont like this, loop does inderect loading of packages
      # can be confusing
      Logger.write @packages.inspect
      return @packages
    end


    def self.find(package_name)
      #TODO
      self.all[package_name].first
    end


    # Used in DSL files
    def self.package(name,options = {},&block)
      package = self.new
      package.name(name)
      package.instance_eval(&block)

      @packages ||= {}
      @packages[package.name] ||= []
      @packages[package.name] << package
    end


    # Part of our DSL
    #Instance methods
    def name(name = nil)
      return @name unless name

      @name = name
      Logger.write "setting name #{name}"
    end

    def type(type)
      @type = type
      self.extend eval(type)
      Logger.write "setting type: #{type}"
    end

    def source(source_uri)
      @files << source_uri
      Logger.write "adding #{source_uri} to files list"
      @version = version
    end

    def prefix(install_prefix)
      @install_prefix = install_prefix
      Logger.write "Changing install prefix to #{install_prefix}"
    end
    
    def patches(patches)
      @patches += patches if patches.is_a? Array
      @patches << patches if patches.is_a? String
      Logger.write "Adding Patches #{patches}"
    end


    # End of DSL
    #####################

    # String representation of kita instance
    # eg gnome-terminal-2.29.3
    def to_s
      [@name,@version].join "-"
    end
    
    # Creates Kita object and parses all the information
    def initialize

      @dependencies = []
      @patches = []
      @files = []
      @files ||= get_files_from_repo
      @version =  version
      @dependencies = []
      @install_prefix = "/usr"

    end
     
     
    # THIS IS THE RECURSIVE THINGY TODO
    # by given action 
    # :install ,:remove
    def call(action)

      for dependency in @dependencies
        Kita.find(dependency).call(action)
      end

      case action
        when :install
          download unless downloaded?

          #TODO Clean
          puts "Installing #{self.to_s}".bold.green unless installed?
          install unless installed?
        when :remove
          remove if installed?
      end

    end
     
     
    # Downloads all files in @files var, returns true if all files downloaded successfully
    def download
      success=true
      for file in files_list_to_download
        success = (success and Downloader.download_file(file))
      end
      return success
    end

    # Checks if all files are downloaded
    def downloaded?
      results = true
      for file in files_list_local 
        results = (results && File.exists?(file))
      end
      return results
    end
    
    

    # This is a default install action, modules should be implementing this
    # kept here for sentemental purposes
    def install
      raise "please write install instructions for this package"
    end

    # Checks if package is installed
    def installed?
      File.exist?(Config::STATE_DIR+'/'+self.to_s)
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
      list.map {|x| Config::SRC_DIR+'/'+ File.basename(x) }
    end

    # Fills FILES var with files maching in repository
    def get_files_from_repo

      FilesDatabase.update_src_files_database if not File.exist?(Config::SRC_MARSHAL_FILE)

      @@files_list_database ||= Marshal.load(IO.read(Config::SRC_MARSHAL_FILE))
      @@files_list_database[@name] ? [@@files_list_database[@name]] : []
    end

    # helper method used to set @version
    # It will find version of first file availible for package
    # or return undefined which is bad, and prob should be an exception
    def version
      @files.first ? File.version(@files.first) : 'undefined'
    end

     # Create a state file meaning that package is installed
     # Please note this parent method creates empty files
     # Child modules overwrite this
     def record_installed
      `touch #{state_file}`
    end
    
   # Removes all files listed in state file, and removes the state file
   def remove
    for line in IO.read(Config::STATE_DIR+'/'+ self.to_s).lines.to_a.reverse
      puts line
    end
   end

    # Location of state file for kita
    def state_file
      Config::STATE_DIR+'/'+self.to_s
    end
  end
end
