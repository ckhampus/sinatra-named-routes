# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'sinatra/version'

Gem::Specification.new do |s|
  s.name        = 'sinatra-named-routes'
  s.version     = Sinatra::NamedRoutes::VERSION
  s.authors     = ['Cristian Hampus']
  s.email       = ['contact@cristianhampus.se']
  s.homepage    = 'https://github.com/ckhampus/sinatra-named-routes'
  s.summary     = %q{Named Routes for Sinatra}
  s.description = %q{Allows the use of named routes in Sinatra applications.}

  s.rubyforge_project = 'sinatra-named-routes'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'sinatra'
end
