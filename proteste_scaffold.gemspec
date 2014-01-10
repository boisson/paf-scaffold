# -*- encoding: utf-8 -*-
require File.expand_path('../lib/proteste_scaffold/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rodrigo Toledo"]
  gem.email         = ["rtoledo@proteste.org"]
  gem.description   = %q{Create a scaffold files for Proteste projects}
  gem.summary       = "Proteste Scaffold"
  gem.name          = "proteste_scaffold"
  gem.homepage      = ""

  gem.files         = Dir["lib/**/*"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.version       = ProtesteScaffold::VERSION
  # gem.add_runtime_dependency('pg')
  gem.add_runtime_dependency('rails','3.2.13')
  # gem.add_runtime_dependency('rails','4.0.0')
  gem.add_runtime_dependency('jquery-rails','2.1.4')
  gem.add_runtime_dependency('remotipart','~> 1.0')
  gem.add_runtime_dependency('therubyracer')
  gem.add_runtime_dependency('less-rails')
  gem.add_runtime_dependency('twitter-bootstrap-rails')
  gem.add_runtime_dependency('simple_form')
  gem.add_runtime_dependency('will_paginate')
  gem.add_runtime_dependency('paperclip')
  gem.add_runtime_dependency('ckeditor')
  gem.add_runtime_dependency('paper_trail')
  gem.add_runtime_dependency('roo', '1.10.2')
  gem.add_runtime_dependency('simple_xlsx_writer')
  gem.add_runtime_dependency('acts_as_xlsx')
  gem.add_runtime_dependency('prawn')
  gem.add_runtime_dependency('ZenTest', '4.8.3')  #don`t work in 4.0.0.
  # gem.add_runtime_dependency('ZenTest', '4.9.3')
  gem.add_runtime_dependency('rspec')
  gem.add_runtime_dependency('rspec-rails')
  gem.add_runtime_dependency('ransack', '0.7.2')
  gem.add_runtime_dependency('rubyzip', '~> 0.9.9')
  gem.add_runtime_dependency('simplecov', '0.7.1')
  gem.add_runtime_dependency('simplecov-rcov', '0.2.3')
end
