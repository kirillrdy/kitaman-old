module Kitaman
  class Error
    # Standart way for Kitaman to notify user of an error
    def kita_error(string)
      puts "KITAMAN ERROR: #{string}".bold.red
      exit 1
    end
  end
end
