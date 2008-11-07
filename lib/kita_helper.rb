ARCHIVE_EXT=['.tar.bz2','.tar.gz']

def smart_split(dict,key)
  dict[key] ? dict[key] = dict[key].split(" ") : dict[key]=[]
  return dict
end

def smart_set(dict,key,default)
  if not dict[key]
    dict[key]=default
  end
 return dict
end

def smart_basename(file)
  file = File.basename(file)
  file.slice(0,file.rindex("-"))
end

def get_version_from_file(file)
  ext = file.slice(file.rindex("-")+1,file.length)
  for extention in ARCHIVE_EXT
    if ext.index extention
      ext = ext.slice(0,ext.index(extention))
    end
  end
  return ext
end

