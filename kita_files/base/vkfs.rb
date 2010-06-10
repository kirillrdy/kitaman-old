extend PreBaby

def installed?
  File.exists?(LFS+"/dev")
end
