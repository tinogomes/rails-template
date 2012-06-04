#This template was based from http://github.com/ryanb/rails-templates/blob/master/base.rb

git :init
 
run "echo 'TODO add readme content' > README"
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/database.yml.sample"
run "rm public/images/rails.png"
run "rm public/index.html"
 
file ".gitignore", <<-GITIGNORE
log/*.log
tmp/**/*
config/*.yml
db/*.sqlite3
GITIGNORE
 
git :add => ".", :commit => "-m 'initial commit'"
