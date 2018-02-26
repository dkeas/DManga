require "bundler/gem_tasks"
require "rake/testtask"
require_relative "lib/dmanga/version"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc "change to second branch"
task :second do system "git checkout second" end

desc "change to master branch"
task :master do system "git checkout master" end

desc "exec the app"
task :exe do system "ruby -Ilib exe/dmanga 'denki ga honya' -v" end

desc "console with app loaded"
task :console do system "bundle exec bin/console" end
