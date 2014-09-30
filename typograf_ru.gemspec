# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "typograf_ru/version"

Gem::Specification.new do |s|
  s.name        = "typograf_ru"
  s.version     = TypografRu::VERSION
  s.authors     = ["Maxim Dorofienko"]
  s.email       = ["dorofienko@gmail.com"]
  s.homepage    = ""
  s.summary     = "Gem adds ability to format russian text by http://typograf.ru for AcitveRecord attributes."
  s.description = "Gem adds ability to format russian text by http://typograf.ru for AcitveRecord attributes."

  s.rubyforge_project = "typograf_ru"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-nc"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-remote"
  s.add_development_dependency "pry-nav"

  s.add_runtime_dependency "rest-client"
end
