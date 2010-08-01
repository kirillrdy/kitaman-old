class Package

  def self.load_all
    puts File.dirname(__FILE__) + '/../../packages/**/*'
    puts Dir[File.dirname(__FILE__) + '/../../packages/**/*'].inspect
    Dir[File.dirname(__FILE__) + '/../../packages/**/*.rb'].each do |x| 
      puts "trying to load #{x}"
      require x
    end
  end

  def self.desribe(&block)
    Package.new.self_eval block
  end


  def self_eval(block)
    block.call
  end

  #Instance methods
  def name(name)
    puts "name #{name}"
    @name = name
  end

end
