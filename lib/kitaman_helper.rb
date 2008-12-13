require 'kitaman/kita_helper'
require 'open-uri'

class Object
  def in(cmp)
    cmp.include? self
  end 
end


def update_src_files_database  
  files_dictionary = {}
  for repo in IO.read(KitamanConfig.config['REPOST_LIST_FILE']).split("\n")
    list_of_files = open(repo).read.scan(/<a href(?:.*?\.tar\.bz2)">(.*?\.tar\.bz2)<\/a>/)
  
    
    for file in list_of_files
      file = file[0]
      puts file
      files_dictionary[file.smart_basename] = repo+file
    end

  end

  File.open('/var/kitaman/src.db','w') { |file|
    file.write(Marshal.dump(files_dictionary))
  }

end

class KitamanConfig
  
  def KitamanConfig.config 
    infos = IO.read('/etc/kitaman.conf').scan(/(.*?)="(.*?)"\n/)
    result = {}
    for info in infos
      result[info[0]]=info[1]
    end
    return result
  end

end

STYLE = {
      :default    =>    "\033[0m",
       # styles
       :bold       =>    "\033[1m",
       :underline  =>    "\033[4m",
       :blink      =>    "\033[5m",
       :reverse    =>    "\033[7m",
       :concealed  =>    "\033[8m",
      # font colors
       :black      =>    "\033[30m",
       :red        =>    "\033[31m",
       :green      =>    "\033[32m",
       :yellow     =>    "\033[33m",
       :blue       =>    "\033[34m",
       :magenta    =>    "\033[35m",
       :cyan       =>    "\033[36m",
       :white      =>    "\033[37m",
       # background colors
       :on_black   =>    "\033[40m",
       :on_red     =>    "\033[41m",
       :on_green   =>    "\033[42m",
       :on_yellow  =>    "\033[43m",
       :on_blue    =>    "\033[44m",
       :on_magenta =>    "\033[45m",
       :on_cyan    =>    "\033[46m",
       :on_white   =>    "\033[47m" }

class String
  def style(st)
    "#{STYLE[st.to_sym]}#{self.to_s}#{STYLE[:default]}"  
  end
end


def set_terminal_title(title)
  puts "\033]0;#{title}\007"
end

