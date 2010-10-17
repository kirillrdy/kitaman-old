class Package
  attr_accessor :info

  def self.all
    #return @packages if @packages
    @packages and return

    @packages ||= Hash.new { [] }
    Dir[File.dirname(__FILE__) + '/../../packages/**/*.rb'].each do |x|
      puts " >> trying to load #{File.basename(x)}"
      package = Package.instance_eval(IO.read(x))
      @packages[package.info[:name]] << package
    end
    return @packages
  end
  
  def initialize
    @info ||= {}
  end
  
  def self.package(name,&block)
    package = self.new
    package.name(name)
    package.instance_eval(&block)
    
    return package
    
  end

  #Instance methods
  def name(name)
    @info[:name] = name
    puts "name #{name}"
  end

  def type(type)
    @info[:type] = type
    puts "SettingType: #{type}"
  end

end
