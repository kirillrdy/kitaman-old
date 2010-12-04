module Kitaman
  class Terminal
    def self.set_title(title)
      puts "\033]0;#{title}\007"
    end
  end
end
