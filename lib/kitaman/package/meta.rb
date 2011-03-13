#    Kitaman - Software Package Manager
#    /-Promise to a little girl and a big world-/
#
#    Copyright (C) 2011  Kirill Radzikhovskyy <kirillrdy@kita-linux.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.



# Meta Module looks after simple 
# packages that mainly have only dependencies 
# and some small shell post install 
#
#
module Kitaman::Package::Meta

  attr_accessor :post_install_cmd

  def set_defaults
    @post_install_cmd = 'echo'
  end

  #TODO fix this to it would support post install methods
  def install
    Shell.execute @post_install_cmd
  end

  

end
