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


  end
end
