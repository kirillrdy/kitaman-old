
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

list = IO.read(ARGV[0]).split("\n")
 
depend_string = ''
for item in list
  File.open(item.smart_basename+'.kita','w') do |file|
    file.write(
    '''KITA_TYPE="xorg"
    ''')
  end
  depend_string << item.smart_basename+" "
end

puts depend_string
