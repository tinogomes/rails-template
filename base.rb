@template_root = File.expand_path(File.join(File.dirname(__FILE__)))

gem "unicorn-rails"

gem_group :development, :test do
  gem "brakeman"
  gem "guard-rspec"
  gem "pry-debugger"
  gem "rspec-rails"
  gem "rubocop"
end

file "README.mkdn", <<-README
# #{@app_name}

TBD
README

file "config/initializers/secret_token.rb", <<-CODE
if ENV['SECRET_TOKEN'].nil? || ENV['SECRET_TOKEN'].empty?
  warn('SECRET_TOKEN is not defined. Try `export SECRET_TOKEN=$(rake secret)`')
  exit 1
end

#{@app_name.classify}::Application.config.secret_key_base = ENV['SECRET_TOKEN']

CODE

run "cp config/database.yml config/database.yml.sample"
run "echo '.rvmrc' >> .gitignore"
run "echo 'config/*.yml' >> .gitignore"
remove_file "README.rdoc"

run "rvm 1.9.3@#{@app_name} --create --rvmrc"

run "bundle"

generate "rspec:install"

file ".rspec", <<-RSPEC
--color
--debugger
--fail-fast
--format doc
--profile
RSPEC

run "guard init rspec"

generate :controller, :home, :index

route "root to: 'home#index'"

git :init
git add: "."
git commit: "-m 'First version'"

puts "Copy those lines into your Guardfile", "\n", <<-GUARDFILE
rspec_options = {
  all_after_pass: false,
  all_on_start: false
}

guard :rspec, options: rspec_options do
  ...
end
GUARDFILE

puts "It's time to get fun!"
