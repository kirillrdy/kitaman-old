module Kitaman
  class ArgumentParser
    def self.parse_argv
      OptionParser.new do |opts|
        opts.banner = "Kitaman version: FIXME
        
  Usage: kitaman.rb [options] packages"

        opts.on("-f", "--force", "Force any action") do |v|
          @options[:force] = v
        end
      
        opts.on("-D", "--deep", "Deep Dependency Calculation") do |v|
          @options[:deep] = v
        end
      
        opts.on("-d", "--download", "Download Only") do |v|
          @options[:build] = false
          @options[:install] = false
          @options[:force] = false
        end

        opts.on("-b", "--build", "Build Only, doesnt install packages") do |v|
          @options[:install] = false
        end
        
        opts.on("-r", "--remove", "Remove the package") do |v|
          @options[:remove] = true
        end
      
        opts.on("-p", "--[no-]pretend", "Pretend") do |v|
          @options[:build] = false
          @options[:install] = false
          @options[:download] = false
        end

        opts.on("-q", "--[no-]quiet", "No questions asked") do |v|
          @options[:quiet] = v
        end
    
        opts.on("-v", "--[no-]verbose", "Run verbosely (Default)") do |v|
          @options[:verbose] = v
        end
        
        opts.on("--graph", "Generate DOT graph (FIXME) ") do |v|
          @options[:graph] = true
          @options[:quiet] = true
        end

        opts.on("--log", "Generate Actions log with results") do |v|
          @options[:save_log]= true
        end
      
        opts.on("-B",'--rebuild-one',"Force rebuild only one package") do |v|
          @options[:force] = true
          @options[:rebuild] = true
        end

        opts.on("-S", "--[no-]sync", "sync") do |v|
          Kitaman.update_src_files_database
          exit
        end
      end.parse!
    end
  end
end
