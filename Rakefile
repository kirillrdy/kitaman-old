#task :default => [:install]
namespace :kitaman do

  task :install, :prefix do |t,args|
    `
      mkdir -p #{args.prefix}/usr/bin
      mkdir -p #{args.prefix}/etc
      mkdir -p #{args.prefix}/var/kitaman/{build,install,config_logs}
      mkdir -p #{args.prefix}/usr/kitaman/{pkg,src,kita_files}

      cp kitaman.rb #{args.prefix}/usr/bin/kitaman
      cp colonel.rb #{args.prefix}/usr/bin/colonel

      mkdir -p #{args.prefix}/usr/lib/ruby/1.9.1/kitaman
      cp lib/* #{args.prefix}/usr/lib/ruby/1.9.1/kitaman/

      cp etc/kitaman.conf #{args.prefix}/etc/
      cp etc/kitaman.repos #{args.prefix}/etc/
      cp -r kita_files #{args.prefix}/usr/kitaman/
    `
        
  end

  task :release do
    TARBALL='kitaman-latest.tar.bz2'
    `cd ../ && tar cjpf #{TARBALL} kitaman/`
    `scp ../#{TARBALL} git@kita-linux.org:files/`
    `rm ../#{TARBALL}`
  end  

end
