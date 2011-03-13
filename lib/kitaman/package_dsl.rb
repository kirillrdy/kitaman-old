module Kitaman
  class PackageDsl
  
    attr_accessor :package

    include Dsl::Make


    # Used in DSL files
    def self.package(name,options = {},&block)
      dsl = self.new
      dsl.package = Package.new

      dsl.package.name = name

      dsl.instance_eval(&block)

      dsl.package.set_defaults
      Kitaman::Package.add dsl.package
    end


    # Part of our DSL
    #Instance methods
    def name(name)
      @package.name = name
      Log.info "setting name #{name}"
    end

    def version(ver)
      @package.version = ver
      Log.info "setting version to #{ver}"
    end

    def type(type)
      if type == :make
        @package.extend Kitaman::Package::Make
        Log.info "setting type: #{type}"
      elsif type == :meta
        @package.extend Kitaman::Package::Meta
        Log.info "setting type: #{type}"
      else
        Error.error "couldnt set type type: #{type}"
      end
    end

    def depends_on stuff
      if stuff.is_a? Array
        @package.dependencies = stuff
        Log.info "setting dependencies to #{stuff.inspect}"
      elsif stuff.is_a? String
        @package.dependencies = [stuff]
        Log.info "setting dependencies to #{[stuff].inspect}"
      else
        Error.error "unsuported type of dependency #{@package.name}"
      end
    end


  end
end
