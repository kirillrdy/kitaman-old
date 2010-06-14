task :default => "kitaman:install"


#RUBY_VERSION='1.9.1'

RUBY_PREFIX=`which ruby`.gsub("/bin/ruby\n","")

kitaman = namespace :kitaman do

  desc 'installs kitaman in a given prefix'
  task :install, :prefix do |t,args|
    install_prefix = args.prefix || RUBY_PREFIX
    kitaman_config_dir = "#{args.prefix}/etc"
    
    puts "Installing Kitaman to #{install_prefix}"
    puts "Config is placed in #{kitaman_config_dir}"

    `
      mkdir -p #{install_prefix}/bin
      mkdir -p #{kitaman_config_dir}
      mkdir -p #{install_prefix}/../var/kitaman/build
      mkdir -p #{install_prefix}/../var/kitaman/install
      mkdir -p #{install_prefix}/../var/kitaman/config_logs
      mkdir -p #{install_prefix}/../var/kitaman/state
      mkdir -p #{install_prefix}/kitaman/pkg
      mkdir -p #{install_prefix}/kitaman/src
      mkdir -p #{install_prefix}/kitaman/kita_files
      mkdir -p #{install_prefix}/lib/ruby/#{RUBY_VERSION}/kitaman
      mkdir -p #{install_prefix}/lib/ruby/#{RUBY_VERSION}/kitaman/modules


      cp kitaman.rb #{install_prefix}/bin/kitaman
      cp colonel.rb #{install_prefix}/bin/colonel
      
      cp modules/* #{install_prefix}/lib/ruby/#{RUBY_VERSION}/kitaman/modules
      cp lib/* #{install_prefix}/lib/ruby/#{RUBY_VERSION}/kitaman/

      cp etc/kitaman_conf.rb #{kitaman_config_dir}
      cp etc/kitaman.repos #{kitaman_config_dir}
      cp -r kita_files #{install_prefix}/kitaman/
    `
    puts 'Done !'
  end

  task :release do
    TARBALL='kitaman-latest.tar.bz2'
    `cd ../ && tar cjpf #{TARBALL} kitaman/`
    `scp ../#{TARBALL} git@kita-linux.org:files/`
    `rm ../#{TARBALL}`
  end
    
end

task :install => [kitaman[:install]]

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
