module Kitaman
  class Shell
    def self.execute(command)
      Log.info "Executing: #{command}"
      result = system(command)
      if not result
        #TODO add logging
        Error.error "Error executing: #{command}".bold.red
        exit 1
      end
      return result

    end
  end
end
