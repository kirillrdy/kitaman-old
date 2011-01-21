# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kitaman/version"

Gem::Specification.new do |s|
  s.name        = "kitaman"
  s.version     = Kitaman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kirill Radzikhovskyy"]
  s.email       = ["kirillrdy@kita-linux.org"]
  s.homepage    = ""
  s.summary     = %q{Kitaman - Best package manager ever}
  s.description = %q{Kitaman is a working horse of kita linux}

  s.rubyforge_project = "kitaman"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
