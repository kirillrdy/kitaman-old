module Kitaman
  class Logger
    def self.init
      @log = Object::Logger.new(STDOUT)
    end

    def self.write stuff
      @log.info stuff
    end

    def self.error stuff
      @log.error stuff
    end

  end
end
