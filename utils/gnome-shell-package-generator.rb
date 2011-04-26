
def package_for package_name, dependencies = []
  puts <<-EOS

package '#{package_name}' do
  type :make
  depends_on #{dependencies.inspect}
end

  EOS
end


require 'nokogiri'

doc = Nokogiri::XML(IO.read('gnome-shell.modules.xml'))
DEPENDENCIES_LIST  = {}

list_of_nodes = [:autotools,:metamodule,:tarball]
list_of_nodes.each do |node|
  (doc/node).each do |package|
    package_name = package.attributes['id']
    (package/:dep).each do |dep|

      DEPENDENCIES_LIST[package_name] ||= []
      DEPENDENCIES_LIST[package_name] << dep.attributes['package'].value

      #puts "  \"#{package_name}\" -> \"#{ dep.attributes['package']}\""
    end
  end
end


DEPENDENCIES_LIST.keys.each do |package_name|
  package_for package_name, DEPENDENCIES_LIST[package_name]
end
