desc 'install all possible dependencies'
task :setup => :gem_installer do
  GemInstaller.new do
    # core

    # spec
    gem 'bacon'
    gem 'rcov'

    # doc
    gem 'yard'

    setup
  end
end
