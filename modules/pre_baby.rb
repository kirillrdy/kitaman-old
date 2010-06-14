module PreBaby
  LFS='/mnt/kita_baby'
  
  def build_enviroment
    new_env = <<-EOF
# This is special Enviroment for Temp Tool Chain
      #set +h
      umask 022
      LFS=#{LFS}
      LC_ALL=POSIX
      LFS_TGT=$(uname -m)-kita-linux-gnu
      PATH=/tools/bin:/bin:/usr/bin
      export LFS LC_ALL LFS_TGT PATH
# END of Temp Tool Chain Enviroment
    EOF
    return (new_env + super)
  end
  
end
