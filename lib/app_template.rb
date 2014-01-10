remove_file "README.rdoc"
create_file "README.md", "TODO"

gsub_file 'Gemfile', "gem 'jquery-rails'", "# gem 'jquery-rails'"
gsub_file 'Gemfile', /gem 'rails'/, "# gem 'rails'"
gem 'rails', '3.2.12'
gem 'proteste_scaffold', :path => '~/www/proteste-scaffold'
gem "rspec", group: [:test, :development]
gem "rspec-rails", group: [:test, :development]
gem 'rspec-mocks', group: [:test, :development]
gem 'autotest', group: [:test, :development]

if yes? "Do you want to generate a .rvmrc file?"
  name = ask("What is the gemset name?").underscore
  create_file ".rvmrc", "rvm use 1.9.2@#{name} --create"
  run "rvm 1.9.2@#{name} --create"
end

run "bundle install"
generate "simple_form:install --bootstrap"
generate "ckeditor:install --orm=active_record --backend=paperclip"
generate "rspec:install"
generate "proteste_scaffold:install"
run "rake db:migrate"

if yes? "Do you want to generate a root controller?"
  name = ask("What should it be called?").underscore
  generate :controller, "#{name} index"
  route "root to: '#{name}\#index'"
  remove_file "public/index.html"
end

git :init
append_file ".gitignore", "config/database.yml"
run "cp config/database.yml config/example_database.yml"
git add: ".", commit: "-m 'initial commit'"