#!/usr/bin/ruby 


#    Cylin - Push fresh kita-linux builds to the Public
#    /-Promise to a little girl and a big world-/
#
#    Copyright (C) 2009  Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
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

require 'erb'


@html_template = '
<html>
<table>
  
  <tr>
    <th>
      Package
    </th>
    <th>
      download
    </th>
    <th>
      build
    </th>
    <th>
      install
    </th>
  </tr>
  
  <% for package_name in @data.keys %>
  <% package = @data[package_name] %>
  <tr>
    <td>
      <%= package_name %>
    </td>
    
    <% for action %>
    
  </tr>
  

  <% end %>

</table>
</html>
'




def log_to_html(hash_id,filename = '/var/kitaman/kitaman.log')

  @log  = IO.read(filename).lines 

  mighty_hash = {}
  
  for line in @log
    stuff = line.split(':')
    app = stuff[0].split("-")[0]
    ver = stuff[0].split("-")[1]
    action = stuff[1]
    pass_fail = stuff[2]
    
    #puts "#{app} #{ver} #{action} #{pass_fail}"    
   
    # this splits by app and ver
    #mighty_hash[app] ||= { ver => { action => pass_fail } }
    
    mighty_hash[app+'-'+ver] ||= { } 
    mighty_hash[app+'-'+ver][action] = pass_fail 
      

  end

  @data = mighty_hash

  html =  ERB.new(@html_template)
  return html.result
end

puts log_to_html('some hash')


