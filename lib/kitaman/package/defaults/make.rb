module Kitaman::Package::Defaults::Make

  # Using best tools and knowledge we will get missing information
  def auto_fill
    @version = get_version_from_sources
    @sources = get_files_from_repo if @sources.empty?
  end

  # Fills FILES var with files maching in repository
  def get_files_from_repo
    FilesDatabase.update_src_files_database if not File.exist?(Config::SRC_MARSHAL_FILE)

    @@files_list_database ||= Marshal.load(IO.read(Config::SRC_MARSHAL_FILE))
    @@files_list_database[@name] ? [@@files_list_database[@name]] : []
  end

  # helper method used to set @version
  # It will find version of first file availible for package
  # or return undefined which is bad, and prob should be an exception
  def get_version_from_sources
    files.first ? File.version(@files.first) : 'undefined'
  end

end
