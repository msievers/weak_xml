require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :benchmark do
  puts File.read("/proc/cpuinfo") if File.exist?("/proc/cpuinfo")

  require_relative "./benchmark/weak_xml/weak_xml_versus_others"
  Benchmark::WeakXml::WeakXmlVersusOthers.new.call
end
