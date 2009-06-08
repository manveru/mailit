Gem::Specification.new do |s|
  s.name = "mailit"
  s.version = "2009.06.08"

  s.summary = "RFC compliant MIME email generation and SMTP mailing."
  s.description = "Simple to use class to generate RFC compliant MIME email."
  s.platform = "ruby"
  s.has_rdoc = true
  s.author = "Michael 'manveru' Fellinger"
  s.email = "m.fellinger@gmail.com"
  s.homepage = "http://github.com/manveru/mailit"
  s.require_path = "lib"

  s.files = [
    "README.md",
    "lib/mailit.rb",
    "lib/mailit/mail.rb",
    "lib/mailit/mailer.rb",
    "lib/mailit/mime.rb",
    "mailit.gemspec",
    "spec/helper.rb",
    "spec/mailit/mail.rb",
    "spec/mailit/mailer.rb",
  ]
end
