require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

# task :default => :test
task :default => :test

desc "change to second branch"
task :second { system "git checkout second" }

desc "change to master branch"
task :master { system "git checkout master" }

desc "exec the app"
task :exe {system "ruby -Ilib exe/mangad gabriel"}

desc "console with app loaded"
task :console {system "bundle exec bin/console"}
