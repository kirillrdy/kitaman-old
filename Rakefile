require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "kitaman"
    gem.summary = %Q{Kitaman - Best Package Manager in the world}
    gem.description = %Q{Kitaman - is package manager for Kita Linux}
    gem.email = "kirillrdy@silverpond.com.au"
    gem.homepage = "http://github.com/kirillrdy/kitaman"
    gem.authors = ["Kirill Radzikhovskyy"]
    #gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    
    #gem.files += Dir['lib/**/*.rb']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end



task :release do
  TARBALL='kitaman-latest.tar.bz2'
  `cd ../ && tar cjpf #{TARBALL} kitaman/`
  `scp ../#{TARBALL} git@kita-linux.org:files/`
  `rm ../#{TARBALL}`
end


task :doc do
  `rm -rf doc/
  rdoc`
end

task :clean do
  `rm -rf /var/kitaman/install/*
  rm -rf /var/kitaman/build/*
  rm -rf /usr/kitaman/pkg/*
  `
end
