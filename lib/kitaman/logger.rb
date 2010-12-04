module Kitaman
  class Logger
    def self.init
      @log = Logger.new(STDOUT)
    end

    def self.write stuff
      @log.info stuff
    end

    def self.error
      @log.error stuff
    end

  end
end
