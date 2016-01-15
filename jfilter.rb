# JsonFilter

require_relative 'lib/config'
require_relative 'lib/crawler'
require_relative 'lib/filter'
require_relative 'lib/source'
require 'optparse'

begin
  OptionParser.new do |options|
    options.banner = "JsonFilter allows to format JSON data.\nAuthor: Roxanne Courchesne\nThe MIT License (MIT)\nCopyright (C) 2016 Roxanne Courchesne, VMC\n\nUsage: jfilter.rb [options]\nArguments (* denotes default option):"

    options.on('-h', '--help', 'Prints this help') do
      puts options
      exit 0
    end
    options.on('-s', '--source SOURCE', 'Specify the source data in JSON format. Source can be either an URL (HTTP only), a path to a local file or a JSON formatted string') do |source|
      raise ArgumentError, 'Source cannot be empty' if source == '' || source == nil
      JsonFilter::Config.instance.source = source
    end
    options.on('-f', '--filter FILTER', 'Specify the filter to use. Can be either an URL (HTTP only), a path to a local file or a JSON formatted string') do |filter|
      raise ArgumentError, 'Source cannot be empty' if filter == '' || filter == nil
      JsonFilter::Config.instance.filter = filter
    end
    options.on('-o', '--out OUTPUT', '[./filtered.json*] Specify where to write the results') do |output|
      JsonFilter::Config.instance.out = output
    end
    options.on('-r', '--root ROOT', 'Narrow down the filtering to a node; all keys in the filter will be relative to this root') do |root|
      JsonFilter::Config.instance.root = root
    end
    options.on('--root-is-array TOGGLE', '[on/off*] Indicate the root of SOURCE is an array and to apply the filter to each of its member') do |toggle|
      raise ArgumentError, 'Expecting option --root-is-array to be either \'on\' or \'off\'' unless ['on', 'off'].include?(toggle)
      JsonFilter::Config.instance.filter_type = 'loop_array'
    end
  end.parse!
rescue ArgumentError => e
  puts 'Invalid argument:'
  puts e.message
  exit 1
rescue OptionParser::InvalidArgument => e
  puts 'Invalid argument:'
  puts e.message
  exit 1
rescue OptionParser::InvalidOption => e
  puts 'Invalid option:'
  puts e.message
  exit 1
rescue OptionParser::MissingArgument => e
  puts 'An option is missing its argument:'
  puts e.message
  exit 1
end

puts 'JsonFilter'
puts '-----------------------------'
puts "Source: #{JsonFilter::Config.instance.source}"
puts "Filter: #{JsonFilter::Config.instance.filter}"
puts "Out: #{JsonFilter::Config.instance.out}"
puts "Root: #{JsonFilter::Config.instance.root}"
puts "Filter type: #{JsonFilter::Config.instance.filter_type}"
puts ''
puts 'Filtering...'

begin
  filter = JsonFilter::Filter.create
  filtered = filter.do(JsonFilter::Source.create(JsonFilter::Config.instance.source, JsonFilter::Config.instance.root))
  File.open(JsonFilter::Config.instance.out, 'w') { |file| file.write(filtered.to_json) }
rescue RuntimeError => e
  puts 'Failed with error:'
  puts e.message
  exit 2
end

if filter.has_errors?
  puts 'Completed with errors...'
  puts filter.errors
else
  puts 'Completed successfully'
end