require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc "change to second branch"
task :second { `git checkout second` }

desc "change to master branch"
task :master { `git checkout master` }

desc "exec the app"
task :exe {`ruby -Ilib exe/mangad grabriel`}
