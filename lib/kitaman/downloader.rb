module Kitaman
  class Downloader

    # Helper used to download singe file
    # Works with partial downlods
    # during donwload keeps it in temp dir
    def self.download_file(file)
      result = true

      if File.exists?("#{Config::SRC_DIR}/#{File.basename(file)}")
        execute_command("mv #{Config::SRC_DIR}/#{File.basename(file)} #{Config::TEMP_DIR}/")
      end

      result = (result && execute_command("wget -c #{file} -O #{Config::TEMP_DIR}/#{File.basename(file)}"))
      result = (result && execute_command("mv #{Config::TEMP_DIR}/#{File.basename(file)} #{Config::SRC_DIR}/"))
      return result
    end

  end
end
