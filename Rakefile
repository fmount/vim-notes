require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/vim_notes_spec.rb'
end

RSpec::Core::RakeTask.new(:cbox) do |t|
  t.pattern = 'spec/fast_export_spec.rb'
end

task :default => :spec

