app_name = ask('What is the name of your app?')

gem_group :development, :test do
  gem "brakeman"
  gem "guard-rspec"
  gem "pry-debugger"
  gem "rspec-rails"
  gem "rubocop"
end

file "config/initializers/secret_token", <<-CODE
if ENV['SECRET_TOKEN'].empty?
  warn('SECRET_TOKEN is not defined. Try `export SECRET_TOKEN=$(rake secret)`')
  exit 1
end

file "README.mkdn", <<-README
# #{app_name}

TBD
README

#{app_name}::Application.config.secret_key_base = ENV['SECRET_TOKEN']

CODE

run "cp config/database.yml config/database.yml.sample"

run "echo '.rvmrc' >> .gitignore"
run "echo 'config/*.yml' >> .gitignore"

git :init
git add: "."
