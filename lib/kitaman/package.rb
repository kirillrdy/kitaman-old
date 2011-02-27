module Kitaman
  class Package

    attr_accessor :name, :version, :type, :dependencies, :post_install_cmd

    def self.add package
      @packages ||= {}
      @packages[package.name] ||= []
      @packages[package.name] ||= << package
    end

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
      Error.error "package #{package_name} not found" unless self.all[package_name]
      self.all[package_name].first
    end


    # Creates Kita object and parses all the information
    def initialize
      @name = 'UNDEFINED PACKAGE'
      @type = :basic
      @dependencies = []
      @post_install_cmd = ''
    end

    # String representation of kita instance
    # eg gnome-terminal-2.29.3
    def to_s
      [@name,@version].join "-"
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

          #TODO Clean
          puts "Installing #{self.to_s}".bold.green unless installed?
          install unless installed?
        when :remove
          remove if installed?
      end

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

    # Create a state file meaning that package is installed
    # Please note this parent method creates empty files
    # Child modules overwrite this
    def record_installed
    `touch #{state_file}`
    end

    ##############################################################################
    private
    ##############################################################################

    # Location of state file for kita
    def state_file
      Config::STATE_DIR+'/'+self.to_s
    end
  end
end
