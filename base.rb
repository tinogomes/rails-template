# encoding: utf-8
@available_gems = []

def installed?(gemname)
  @available_gems.include?(gemname)
end

def want_gem(gemname)
  @available_gems << gemname
  gem gemname if yes?("Would you like to use #{gemname}?")
end

run "/bin/bash -lc 'rvm #{ENV['RUBY_VERSION']}@#{app_name} --create --ruby-version'"

want_gem 'unicorn-rails'

gem_group :development do
  want_gem 'brakeman'
  want_gem 'rubocop'
end

gem_group :development, :test do
  gem 'dotenv-rails'
  want_gem 'guard-rspec'
  gem 'pry-debugger'
  gem 'rspec-rails'
end

create_file 'README.mkdn', <<-README
# #{app_name}

TBD

README

initializer 'secret_token.rb', <<-CODE
if ENV['SECRET_TOKEN'].nil? || ENV['SECRET_TOKEN'].empty?
  warn('SECRET_TOKEN is not defined. Try `export SECRET_TOKEN=$(rake secret)`')
  exit 1
end

#{app_const_base}::Application.config.secret_key_base = ENV['SECRET_TOKEN']

CODE

create_file '.env', "SECRET_TOKEN=#{app_secret}"

run 'cp config/database.yml config/database.yml.sample'
append_file '.gitignore', '/.ruby-*'
append_file '.gitignore', '/config/*.yml'
remove_file "README.rdoc"

run 'bundle'

generate 'rspec:install'
get 'https://gist.github.com/tinogomes/6082570/raw/e7cb366b0376a594d3928a8bb744e4a154e671e8/.rspec', '.rspec'

if installed?('guard-rspec')
  run "guard init rspec"

  gsub_file 'Guardfile', 'guard :rspec do', <<-EOF
  rspec_options = {
    all_after_pass: false,
    all_on_start: false
  }

  guard :rspec, options: rspec_options do
  EOF
end

if yes?('Do you want Home controller?')
  generate :controller, :home, :index

  route "root to: 'home#index'"
end

rake 'db:create:all'
rake 'db:migrate'
rake 'db:test:prepare'
rake 'spec'

git :init
git add: '.'
git commit: '-m "It\'s time to get fun!"'

puts ""
