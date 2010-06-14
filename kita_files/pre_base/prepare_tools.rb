extend PreBaby

def install
  execute_command("mkdir -vp #{LFS}/tools")
  execute_command "ln -sv #{LFS}/tools /"
end

def installed?
  File.exists?("#{LFS}/tools")
end
