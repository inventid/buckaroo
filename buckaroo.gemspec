# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "buckaroo/version"

Gem::Specification.new do |s|
  s.name         = %q{buckaroo}
  s.version      = Buckaroo::VERSION
  s.authors      = ["Rogier Slag"]
  s.description  = %q{Buckaroo payment gateway (see http://www.buckaroo.nl)}
  s.summary      = %q{Buckaroo payment gateway}
  s.email        = %q{rogier@inventid.nl}

  s.homepage     = %q{http://opensource.inventid.nl/buckaroo}

  s.extra_rdoc_files = [
     "LICENSE",
     "README.md"
   ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency             "addressable"

  s.add_development_dependency "rspec"
  s.add_development_dependency "mocha"

end
