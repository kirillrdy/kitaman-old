task :default => "kitaman:install"

#RUBY_VER='1.8'
RUBY_VER='1.9.1'

namespace :kitaman do
  
  
  desc 'installs kitaman in a given prefix'
  task :install, :prefix do |t,args|
    puts 'Installing kitaman ...'
    `

      mkdir -p #{args.prefix}/usr/bin
      mkdir -p #{args.prefix}/etc
      mkdir -p #{args.prefix}/var/kitaman/build
      mkdir -p #{args.prefix}/var/kitaman/install
      mkdir -p #{args.prefix}/var/kitaman/config_logs
      mkdir -p #{args.prefix}/var/kitaman/state
      mkdir -p #{args.prefix}/usr/kitaman/pkg
      mkdir -p #{args.prefix}/usr/kitaman/src
      mkdir -p #{args.prefix}/usr/kitaman/kita_files
      mkdir -p #{args.prefix}/usr/lib/ruby/#{RUBY_VER}/kitaman

      cp kitaman.rb #{args.prefix}/usr/bin/kitaman
      cp colonel.rb #{args.prefix}/usr/bin/colonel
      
      cp lib/* #{args.prefix}/usr/lib/ruby/#{RUBY_VER}/kitaman/
      cp lib/tree.rb #{args.prefix}/usr/lib/ruby/#{RUBY_VER}/

      cp etc/kitaman.conf #{args.prefix}/etc/
      cp etc/kitaman.repos #{args.prefix}/etc/
      cp -r kita_files #{args.prefix}/usr/kitaman/
    `
     #puts args.prefix
  end

  task :release do
    TARBALL='kitaman-latest.tar.bz2'
    `cd ../ && tar cjpf #{TARBALL} kitaman/`
    `scp ../#{TARBALL} git@kita-linux.org:files/`
    `rm ../#{TARBALL}`
  end
    
end

task :clean do
  `rm -rf /var/kitaman/install/*
  rm -rf /var/kitaman/build/*
  rm -rf /usr/kitaman/pkg/*
  `
end
