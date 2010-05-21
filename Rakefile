require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "pokereval"
    gem.summary = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "wizardwerdna@gmail.com"
    gem.homepage = "http://github.com/wizardwerdna/pokereval"
    gem.authors = ["Andrew Greenberg"]
    gem.add_development_dependency "rspec", ">= 2.0.0.beta.8"
    gem.add_development_dependency "cucumber", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue MissingSourceFile 
  module Rspec
    module Core
      class RakeTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

            # ... otherwise, do this:
            raise <<-MSG

#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
#{"*" * 80}
MSG
          end
        end
      end
    end
  end
end

task :default => :spec

desc "Run all specs in spec directory (excluding plugin specs)"
Rspec::Core::RakeTask.new()
namespace :spec do
  [:requests, :models, :controllers, :views, :helpers, :mailers, :lib].each do |sub|
    desc "Run the code examples in spec/#{sub}"
    Rspec::Core::RakeTask.new() do |t|
      t.pattern = "./spec/#{sub}/**/*_spec.rb"
    end
  end
end
task :spec => :check_dependencies

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pokereval #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
