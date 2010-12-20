module Kitaman
  class PackageDsl
  
    attr_accessor :package


    # Used in DSL files
    def self.package(name,options = {},&block)
      dsl = self.new
      dsl.package = Package.new

      dsl.package.set_name name

      dsl.instance_eval(&block)

      return dsl.package
    end


    # Part of our DSL
    #Instance methods
    def name(name)
      @package.set_name name
      Log.info "setting name #{name}"
    end

    def type(type)
      @package.set_type type
      Log.info "setting type: #{type}"
    end

    def source(source_uri)
      @package.add_source source_uri
      Log.info "adding #{source_uri} to files list"
    end

    def prefix(install_prefix)
      @package.set_prefix install_prefix
      Log.info "Changing install prefix to #{install_prefix}"
    end

    def patch patch
      @package.add_patch patch
      Log.info "Adding Patch #{patche}"
    end

    def patches(patches)
      @package.add_patches patches
      Log.info "Adding Patches #{patches}"
    end

  end
end
