Gem::Specification.new do |s|
  s.name = 'mini_pgm'
  s.version = '0.0.1'
  s.date = '2021-06-04'
  s.summary = 'Minimal PGM library for Ruby'
  s.description = 'A minimal Probabilistic Graphical Model library for Ruby (very experimental)'
  s.homepage = 'https://github.com/tristanpenman/mini-pgm'
  s.license = 'MIT'
  s.authors = ['Tristan Penman']
  s.email = 'tristan@tristanpenman.com'

  s.files = Dir.glob('{bin,lib}/**/*')

  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rubocop', '~> 1.16.0'
  s.add_development_dependency 'simplecov', '~> 0.21.2'
end
