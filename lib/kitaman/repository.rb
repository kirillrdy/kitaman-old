class Kitaman::Repository

  #TODO fix in the future
  def self.fake_list_of_repositories
    @repositories = ['git@kitaman.org:packages/kita-linux.git']
  end

  def self.init
    Logger.info 'Initialising Repositories'
    @repositories = self.fake_list_of_repositories

    Repository.all.each do |repository|
      repository.clone unless repository.exists?
    end

  end

  def self.all
    @repositories.map {|x| self.new x }
  end

  def initialize(url)
    @url = url
    @base_path = User.current_user.is_root? ? Config::REPOSITORIES_BASE_PATH : "${HOME}/kitaman_repositories"
    @repository_name = File.basename @url, '.git'
  end

  def clone
    # TODO fix with some sort of rc file
    Logger.info "Cloning #{@url} to #{@base_path}/#{@repository_name}"
    Shell.execute "cd #{@base_path} && git clone #{@url} #{@repository_name}"
  end

  def exists?
    File.exists? "#{base_path}/#{repository_name}"
  end

end
