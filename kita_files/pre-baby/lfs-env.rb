@version = '0.0'

def downloaded?
  true
end

def installed?
  puts 'testing env...'
  
  puts "true" if ENV['LFS'] != nil
  
  ENV['LFS'] != nil
end

def install
  puts 'installing env...'
  system "
  export LFS=/mnt/lfs
  mkdir -vp $LFS/tools
  ln -sfv $LFS/tools /
  "
end
