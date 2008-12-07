ARCHIVE_EXT=['.tar.bz2','.tar.gz']

class Hash
  def set_if_nil(key,default)
    if not self[key]
      self[key]=default
    end
  end
 
  def split_or_default_if_nil(key,default)
    self[key] ? self[key] = self[key].split(" ") : self[key]= default
  end  
end

class String
  def smart_basename
    File.basename(self).slice(0,self.rindex(/-\d/))
  end
  def version
    #puts self
    ext = self.slice(self.rindex(/-\d/)+1,self.length)
    for extention in ARCHIVE_EXT
      if ext.index extention
        ext = ext.slice(0,ext.index(extention))
      end
    end
    return ext
  end
end
