module Kitaman
  class Error
    # Standart way for Kitaman to notify user of an error
    def self.error(string)
      Log.error "KITAMAN ERROR: #{string}".bold.red
      exit 1
    end
  end
end
