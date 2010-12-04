module Kitaman
  module TerminalColours
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


    def method_missing(*args)
      colour = args[0]
      return [STYLE[colour.to_sym],self.to_s,STYLE[:default]].join if STYLE[colour.to_sym]
      super *args
    end
  end

end

class String
  include Kitaman::TerminalColours
end
