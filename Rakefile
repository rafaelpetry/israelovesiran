require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  #test.name = 'simplecov'
  test.loader = :direct # uses require() which skips PWD in Ruby 1.9
  test.libs << 'lib' << 'test' << Dir.pwd
  test.test_files = FileList['test/**/*_test.rb']
  test.ruby_opts.push '-r', 'simplecov', '-e', 'SimpleCov.start'.inspect
  test.verbose = true
end

task default: :test
