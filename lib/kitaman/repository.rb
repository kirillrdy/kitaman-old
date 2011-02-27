module Kitaman
  class Repository
    attr_accessor :url

    #TODO fix in the future
    def self.fake_list_of_repositories
      ['git://kitaman.org/packages/kita-linux.git']
    end

    def self.init
      Log.info 'Initialising Repositories'

      Repository.all.each do |repository|
        repository.clone unless repository.exists?
      end

    end

    def self.all
      fake_list_of_repositories.map {|x| self.new x }
    end

    def initialize(url)
      @url = url
      @base_path = User.current_user.is_root? ? Config::REPOSITORIES_BASE_PATH : "${HOME}/kitaman_repositories"
      @repository_name = File.basename @url, '.git'
    end

    def clone
      # TODO fix with some sort of rc file
      Log.info "Cloning #{@url} to #{@base_path}/#{@repository_name}"
      Shell.execute "cd #{@base_path} && git clone #{@url} #{@repository_name}"
    end

    def pull
      Log.info "Pulling #{@repository_name}"
      Shell.execute "cd #{@base_path}/#{@repository_name} && git pull"
    end

    def full_path
      @base_path + '/' + @repository_name
    end

    def exists?
      File.exists? full_path
    end

    def ruby_files
      Dir["#{full_path}/**/*.rb"]
    end

  end
end
