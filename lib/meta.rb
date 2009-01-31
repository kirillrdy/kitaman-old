load 'kitaman/kita_class.rb'

class Kita

  def build
    puts "Nothing to do for meta package"
    return true
  end
  
  def install    
    if not system("""
      

      post_install()
      {
        echo \"no post install\"
      }

      #{@info["BUILD"]}

      post_install
      
      ldconfig

    """)
      return false
    end
    record_installed
    return true
  end
  
  def download
    puts "Nothing to do for meta package"
    return true
  end
  
end
