class File

  # List of known and supported archives
  ARCHIVE_EXTENSIONS=['.tar.bz2','.tar.gz','.tgz','.bz2']

  # Basename that is much smarter that File.basename
  # eg:
  # "mumbo/linux-2.27.5.tar.bz2".smart_basename ==> 'linux'
  def self.smart_basename(full_filename)
    File.basename(full_filename).slice(0,full_filename.rindex(/-\d/))
  end

  # Getting package version number from package URL
  # "http://mom.org/linux-2.26.4.tar.bz2".version ==> '2.26.4'
  def self.version(full_filename)
    ext = full_filename
    if full_filename.rindex(/-\d/)
      ext = full_filename.slice( full_filename.rindex(/-\d/)+1 ,full_filename.length) 
    end
    for extention in ARCHIVE_EXTENSIONS
      if ext.index extention
        ext = ext.slice(0,ext.index(extention))
      end
    end
    return ext
  end


end

