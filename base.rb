# encoding: utf-8

if options['skip_gemfile']
  puts 'You can not use this template without gemfile, sorry...'
  exit 1
end

if options['skip_git']
  puts 'R U MAD? NO GIT? GET OUT OF HERE!'
  exit 1
end

def remove_comments_for(filename)
  gsub_file filename, /^\s*#.*\n/, ''
end

if yes?("Do you want to create a RVM gemset for #{app_name}")
  run "/bin/bash -lc 'rvm #{ENV['RUBY_VERSION']}@#{app_name} --create --ruby-version'"
end

git :init

append_file '.gitignore', "/.ruby-*\n"
append_file '.gitignore', "/config/*.yml\n"

Dir['./config/*.yml'].each do |filename|
  FileUtils.cp filename, "#{filename}.sample"
end

git add: '.'
git commit: '-m "Rails app base"'

if yes?('Force a Ruby version?')
  ruby_version = ask('Which Ruby version:')
  gsub_file 'Gemfile', /^(source.*)$/, "\\1\n\nruby " + ruby_version.inspect
end

uncomment_lines 'Gemfile', 'bcrypt' if yes?('Use BCrypt?')
uncomment_lines 'Gemfile', 'unicorn' if yes?('Use Unicorn?')
uncomment_lines 'Gemfile', 'capistrano' if yes?('Use Capistrano?')
comment_lines 'Gemfile', 'coffee'
remove_comments_for 'Gemfile'

gem_group :development do
  gem 'brakeman'
  gem 'foreman'
  gem 'mailcatcher'
  gem 'rubocop'
end

gem_group :development, :test do
  gem 'dotenv-rails'
  gem 'guard-rspec'
  gem 'byebug'
  gem 'rspec-rails'
end

gem_group :production do
  # enable gzip compression on heroku, but don't compress images.
  gem 'heroku-deflater' if yes?('Use heroku-deflater?')
  # heroku injects it if it's not in there already
  gem 'rails_12factor'
  gem 'newrelic_rpm' if yes?('Use Newrelic?')
end

run 'bundle install'

git add: '.'
git commit: '-m "gems installed"'

create_file '.env', "SECRET_KEY_BASE=#{`rake secret`}"

generate 'rspec:install'

create_file '.rspec', <<-RSPEC_OPTIONS
--color
--require spec_helper
--format doc
--profile
RSPEC_OPTIONS

run 'guard init rspec'

gsub_file 'Guardfile', 'guard :rspec do', <<-EOF
rspec_options = {
  notification: false
}

guard :rspec, options: rspec_options do
EOF

environment 'config.action_mailer.delivery_method = :smtp', env: 'development'
environment 'config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }', env: 'development'

create_file 'Procfile.development', <<-PROCFILE
#worker: sidekiq
#postgres: postgres -D /usr/local/var/postgres
#elastichsearch: elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml
#redis: redis-server /usr/local/etc/redis.conf
mailcatcher: mailcatcher --foreground --verbose
#web: rails server
PROCFILE

git add: '.'
git commit: '-m "Setup development and test gems"'

if yes?('Do you want Home controller?')
  generate :controller, :home, 'index --no-view-specs --skip-routes --no-helper --no-assets'

  route "root to: 'home#index'"

  git add: '.'
  git commit: '-m "Home controller created!"'
end

unless options['skip_active_record']
  rake 'db:create'
  rake 'db:migrate'
  rake 'spec' if yes?('Is rspec working?')
end if yes?('Create database?')


if yes?('Remove comments for routes file?')
  remove_comments_for 'config/routes.rb'
  git add: '.'
  git commit: '-m "Removed routes comments"'
end

puts 'TODO:'
puts '- Edit README file'
puts '- Override bin/setup file from https://gist.github.com/tinogomes/5aee18de24ba1115a1f2afdb959187c4'
puts '- Check Procfile.development file'
puts '- Check .env file'
puts '- Go work!'
