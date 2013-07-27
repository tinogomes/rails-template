# encoding: utf-8

if options['skip_gemfile']
  puts 'You can not use this template without gemfile, sorry...'
  exit 1
end

run "/bin/bash -lc 'rvm #{ENV['RUBY_VERSION']}@#{app_name} --create --ruby-version'"

def remove_comments_for(filename)
  gsub_file filename, /^\s*#.*\n/, ''
end

def comment_line_on(filename, expression)
  gsub_file filename, Regexp.new("^.*#{expression}.*$"), '# \0'
end

remove_comments_for 'Gemfile'
comment_line_on 'Gemfile', 'coffee'
comment_line_on 'Gemfile', 'turbolinks'

gem 'unicorn-rails'

gem_group :development do
  gem 'brakeman'
  gem 'rubocop'
end

gem_group :development, :test do
  gem 'dotenv-rails'
  gem 'guard-rspec'
  gem 'pry-debugger'
  gem 'rspec-rails'
end

remove_comments_for 'config/routes.rb'

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

remove_file "README.rdoc"

run 'bundle'

generate 'rspec:install'
get 'https://gist.github.com/tinogomes/6082570/raw/e7cb366b0376a594d3928a8bb744e4a154e671e8/.rspec', '.rspec'

run "guard init rspec"

gsub_file 'Guardfile', 'guard :rspec do', <<-EOF
rspec_options = {
  all_after_pass: false,
  all_on_start: false
}

guard :rspec, options: rspec_options do
EOF

if yes?('Do you want Home controller?')
  generate :controller, :home, :index

  route "root to: 'home#index'"
end

if !options['skip_active_record']
  run 'cp config/database.yml config/database.yml.sample'

  rake 'db:create:all'
  rake 'db:migrate'
  rake 'db:test:prepare'
else
  remove_file 'config/database.yml'
end

rake 'spec'

if !options['skip_git']
  append_file '.gitignore', '/.ruby-*'
  append_file '.gitignore', '/config/*.yml'

  git :init
  git add: '.'
  git commit: '-m "It\'s time to get fun!"'
else
  puts 'You are not using Git. O_o'
end

puts 'Remember, you should create the SECRET_TOKEN variable for production.'
