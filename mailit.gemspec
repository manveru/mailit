# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mailit}
  s.version = "2009.08"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Berry"]
  s.date = %q{2009-08-25}
  s.default_executable = %q{}
  s.description = %q{The Mailit library, by Kevin Berry}
  s.email = %q{kevinberry@nrs.us}
  s.executables = [""]
  s.files = ["README.md", "Rakefile", "lib/mailit.rb", "lib/mailit/mail.rb", "lib/mailit/mailer.rb", "lib/mailit/mime.rb", "lib/version.rb", "mailit.gemspec", "spec/helper.rb", "spec/mailit/mail.rb", "spec/mailit/mailer.rb", "tasks/authors.rake", "tasks/bacon.rake", "tasks/changelog.rake", "tasks/copyright.rake", "tasks/gem.rake", "tasks/gem_installer.rake", "tasks/install_dependencies.rake", "tasks/manifest.rake", "tasks/rcov.rake", "tasks/release.rake", "tasks/reversion.rake", "tasks/setup.rake", "tasks/yard.rake", "bin/"]
  s.homepage = %q{http://github.com/manveru/mailit}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{The Mailit library, by Kevin Berry}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
