module Kitaman
  class FilesDatabase
    def self.update
      files_dictionary = {}
      for repo in IO.read(Kitaman::Config::SOURCES_LIST_LOCATION).split("\n")
        puts "Syncing #{repo.blue}"
        list_of_files = open(repo).read.scan(/<a href=\"(.*?\.tar\.bz2)">(?:.*?)<\/a>/)
        
        for file in list_of_files
          file = file[0]
          files_dictionary[File.smart_basename(file)] = repo+file
        end
      end

      File.open(Config::SRC_MARSHAL_FILE,'w') do |file|
        file.write(Marshal.dump(files_dictionary))
      end

    end
  end
end
