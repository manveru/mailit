require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'time'
require 'date'

PROJECT_SPECS = Dir['spec/mailit/**/*.rb']
PROJECT_MODULE = 'Mailit'
PROJECT_README = 'README.md'
PROJECT_VERSION = (ENV['VERSION'] || Date.today.strftime('%Y.%m.%d')).dup

PROJECT_FILES = FileList[`git ls-files`.split("\n")].exclude('.gitignore')

GEMSPEC = Gem::Specification.new{|s|
  s.name         = "mailit"
  s.author       = "Michael 'manveru' Fellinger"
  s.summary      = "The simple way to create mails"
  s.email        = "manveru@rubyists.com"
  s.homepage     = "http://github.com/manveru/mailit"
  s.platform     = Gem::Platform::RUBY
  s.version      = PROJECT_VERSION
  s.files        = PROJECT_FILES
  s.has_rdoc     = true
  s.require_path = 'lib'
}

Dir['tasks/*.rake'].each{|f| import(f) }

task :default => [:bacon]

CLEAN.include %w[
  **/.*.sw?
  *.gem
  .config
  **/*~
  **/{data.db,cache.yaml}
  *.yaml
  pkg
  rdoc
  ydoc
  *coverage*
]
