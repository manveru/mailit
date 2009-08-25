begin; require 'rubygems'; rescue LoadError; end

require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'time'
require 'date'
require "lib/"

PROJECT_SPECS = FileList[
  'spec/*/**/*.rb'
]

PROJECT_MODULE = ''
PROJECT_README = 'README'
#PROJECT_RUBYFORGE_GROUP_ID = 3034
PROJECT_COPYRIGHT_SUMMARY = [
 "# Copyright (c) 2008-#{Time.now.year} The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>",
 "# Distributed under the terms of the MIT license.",
 "# See the LICENSE file which accompanies this software for the full text",
 "#"
]
PROJECT_COPYRIGHT = PROJECT_COPYRIGHT_SUMMARY + [
 "# Permission is hereby granted, free of charge, to any person obtaining a copy",
 '# of this software and associated documentation files (the "Software"), to deal',
 "# in the Software without restriction, including without limitation the rights",
 "# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell",
 "# copies of the Software, and to permit persons to whom the Software is",
 "# furnished to do so, subject to the following conditions:",
 "#",
 "# The above copyright notice and this permission notice shall be included in",
 "# all copies or substantial portions of the Software.",
 "#",
 '# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
 "# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,",
 "# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE",
 "# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER",
 "# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,",
 "# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN",
 "# THE SOFTWARE."
]

PROJECT_VERSION =
  if version = ENV['PROJECT_VERSION'] || ENV['VERSION']
    version
  else
    ::VERSION rescue Date.today.strftime("%Y.%m.%d")
  end

# To release the monthly version do:
# $ PROJECT_VERSION=2009.03 rake release

PROJECT_FILES = FileList[`git ls-files`.split("\n")].exclude('.gitignore')

GEMSPEC = Gem::Specification.new{|s|
  s.name         = ""
  s.author       = "Kevin Berry"
  s.summary      = "The  library, by Kevin Berry"
  s.description  = "The  library, by Kevin Berry"
  s.email        = "kevinberry@nrs.us"
  s.homepage     = ""
  s.platform     = Gem::Platform::RUBY
  s.version      = PROJECT_VERSION
  s.files        = PROJECT_FILES
  s.has_rdoc     = true
  s.require_path = "lib"
  s.bindir       = "bin"
  s.executables  = [""]
  

  s.post_install_message = <<MESSAGE
============================================================

Thank you for installing !

============================================================
MESSAGE
}

Dir.glob('tasks/*.rake'){|f| import(f) }

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
