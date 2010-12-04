module Kitaman
  class Shell
    def self.execute(command)
      result = system(command)
      if not result
        #TODO add logging
        puts "Error executing: #{command}".bold.red
        exit 1
      end
      return result

    end
  end
end
