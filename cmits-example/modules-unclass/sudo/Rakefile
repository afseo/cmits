require 'rake/testtask'
require 'rake'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

# http://stackoverflow.com/questions/9017158/

task :default => [:test, :spec]

Rake::TestTask.new do |t|
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
end

