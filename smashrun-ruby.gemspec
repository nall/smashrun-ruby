Gem::Specification.new do |s|
  s.name        = 'smashrun-ruby'
  s.version     = '1.0.0'
  s.date        = '2016-02-16'
  s.summary     = 'Ruby wrapper for the Smashrun API'
  s.description = 'Implements authentication, reading and writing for the Smashrun API (http://smashrun.com)'
  s.authors     = ['Jon Nall']
  s.email       = 'jon.nall@gmail.com'
  s.files       = ['lib/smashrun.rb']
  s.homepage    = 'https://github.com/nall/smashrun-ruby'
  s.license     = 'BSD-3-Clause'
  s.add_runtime_dependency 'oauth2', '>= 1.1.0'
end
