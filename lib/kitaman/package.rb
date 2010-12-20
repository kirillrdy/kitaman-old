module Kitaman
  class Package

    def self.all
      return @packages if @packages

      @packages ||= {}
      
      Repository.all.each do |repository|
        Log.info "Working on #{repository.url}"
        repository.ruby_files.each do |x|
          Log.info "Loading #{x}"
          PackageDsl.instance_eval(IO.read(x))
        end
      end

      Log.info @packages.inspect
      return @packages
    end


    def self.find(package_name)
      #TODO
      self.all[package_name].first
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



    ###############
    # DSL supporting methods
    def set_name name
      @name = name
    end

    def set_type type
      self.extend(eval(type))
    end

    def add_source source_uri
      @files << source_uri
    end

    def set_prefix prefix
      @install_prefix = prefix
    end

    def add_patch patch
      @patches << patch
    end

    def add_patches patches
      @patches += patches
    end

    # END of DSL methods
    ######

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
