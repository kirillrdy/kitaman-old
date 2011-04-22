module Kitaman
  class FilesDatabase
    def self.update
      files_dictionary = {}
      list_of_repositories = IO.read(Kitaman::Config::SOURCES_LIST_LOCATION).split("\n")
      list_of_repositories.each do |repo|
        puts "Syncing #{repo.blue}"
        list_of_files = open(repo).read.scan(/<a href=\"(.*?\.tar\.bz2)">(?:.*?)<\/a>/)

        list_of_files.each do |file|
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
