# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cukit/version"

Gem::Specification.new do |s|
  s.name        = "cukit"
  s.version     = Cukit::VERSION
  s.authors     = ["Marcus Lankenau"]
  s.email       = ["marcus.lankenau@friendscout24.de"]
  s.homepage    = ""
  s.summary     = %q{Addons for cucumber I like to use}
  s.description = %q{User Bunny/RabbitMQ and SMTP mocking in your tests}

  s.rubyforge_project = "cukit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
