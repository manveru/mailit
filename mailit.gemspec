# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mailit}
  s.version = "2010.06"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael 'manveru' Fellinger"]
  s.date = %q{2010-06-03}
  s.email = %q{manveru@rubyists.com}
  s.files = ["AUTHORS", "CHANGELOG", "MANIFEST", "README.md", "Rakefile", "lib/mailit.rb", "lib/mailit/mail.rb", "lib/mailit/mailer.rb", "lib/mailit/mime.rb", "lib/mailit/version.rb", "lib/version.rb", "mailit.gemspec", "spec/helper.rb", "spec/mailit/mail.rb", "spec/mailit/mailer.rb", "tasks/authors.rake", "tasks/bacon.rake", "tasks/changelog.rake", "tasks/copyright.rake", "tasks/gem.rake", "tasks/gem_installer.rake", "tasks/install_dependencies.rake", "tasks/manifest.rake", "tasks/rcov.rake", "tasks/release.rake", "tasks/reversion.rake", "tasks/setup.rake", "tasks/yard.rake"]
  s.homepage = %q{http://github.com/manveru/mailit}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{The simple way to create mails}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
