class Package

  def self.load_all
    Dir['../../packages/**/*'].each do |x| 
      puts "trying to load #{x}"
      require x
    end
  end

  def self.desribe

  end
  
end
