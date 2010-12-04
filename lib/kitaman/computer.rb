module Kitaman
  class Computer

    # Find how many CPU cores host machine has
    def self.number_of_cores
      results = `cat /proc/cpuinfo | grep cores`.scan(/\: (.*?)\n/)
      results == [] ? 1 : results[0][0].to_i
    end

  end

end
