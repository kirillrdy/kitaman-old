#task :default => [:install]
namespace :kitaman do

  task :install, :prefix do |t,args|
    `./install.sh #{args.prefix}`
    puts args.prefix
  end
end
