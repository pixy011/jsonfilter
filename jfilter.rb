# JsonFilter

require_relative 'lib/config'
require_relative 'lib/crawler'
require_relative 'lib/filter'
require_relative 'lib/source'
require 'optparse'
require 'io/console'

trap("INT") { puts "\n\nShutting down."; exit}

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
    options.on('--root-is-array [TOGGLE]', '[on/off*] Indicate the root of SOURCE is an array and to apply the filter to each of its member') do |toggle|
      raise ArgumentError, 'Expecting option --root-is-array to be either \'on\' or \'off\'' unless ['on', 'off'].include?((toggle ||= 'on'))
      JsonFilter::Config.instance.filter_type = 'loop_array' unless toggle == 'off'
    end
    options.on('--iteration-id KEY', 'Specify a key to identify iteration in error messages') do |key|
      JsonFilter::Config.instance.iteration_id = key
    end
    options.on('--pretty-print [TOGGLE]', 'Indicate if the output should be pretty printed') do |toggle|
      raise ArgumentError, 'Expecting option --root-is-array to be either \'on\' or \'off\'' unless ['on', 'off'].include?(toggle ||= 'on')
      JsonFilter::Config.instance.pretty = toggle == 'on'
    end
    options.on('--http-basic-pass PASS', 'Specify the password to use for HTTP Basic Authentication. To be used with --http-basic-user. Will prompt for password if --http-basic-user is present and this options is omitted.') do |pass|
      JsonFilter::Config.instance.http_basic_pass = pass
    end
    options.on('--http-basic-user [USER]', 'If provided, will attempt to use Basic Authentication with HTTP Sources. Will prompt for user if left blank') do |user|
      if user == nil
        print 'http-basic-user: ';STDOUT.flush
        user = gets.chomp
      end

      JsonFilter::Config.instance.http_basic_user = user
    end
  end.parse!
  if JsonFilter::Config.instance.http_basic_user != nil && JsonFilter::Config.instance.http_basic_pass == nil
    print 'http-basic-pass: ';STDOUT.flush
    STDIN.noecho { |io|
      JsonFilter::Config.instance.http_basic_pass = io.gets.chomp }
  end
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
puts "Http Basic Authentication - User: #{JsonFilter::Config.instance.http_basic_user}" unless JsonFilter::Config.instance.http_basic_user == nil
puts ''
puts 'Filtering...'

begin
  filter = JsonFilter::Filter.create
  filtered = filter.do(JsonFilter::Source.create(JsonFilter::Config.instance.source, JsonFilter::Config.instance.root))
  File.open(JsonFilter::Config.instance.out, 'w') { |file| file.write(JsonFilter::Config.instance.pretty ? JSON.pretty_generate(filtered) : filtered.to_json) }
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
