class Kitaman::User
  def self.current_user
    self.new `whoami`.strip
  end
  
  def initialize username
    @username = username
  end
  
  def whoami
    @username
  end
  
  def is_root?
    whoami == 'root'
  end
  
end
