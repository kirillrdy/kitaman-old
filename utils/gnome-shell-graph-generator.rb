require 'nokogiri'

doc = Nokogiri::XML(IO.read('gnome-shell.modules.xml'))

puts 'digraph gnome_shell {'

list_of_nodes = [:autotools,:metamodule,:tarball]
list_of_nodes.each do |node|
  (doc/node).each do |package|
    package_name = package.attributes['id']
    (package/:dep).each do |dep|
      puts "  \"#{package_name}\" -> \"#{ dep.attributes['package']}\""
    end
  end
end

puts '}'
