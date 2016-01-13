# JsonFilter

Dir['./lib/*.rb'].each {|rblib| require rblib }
require 'optparse'

begin
  OptionParser.new do |options|
    options.banner = "JsonFitler allows to format JSON data.\nAuthor: Roxanne Courchesne\nThe MIT License (MIT)\nCopyright (C) 2016 Roxanne Courchesne, VMC"

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
    options.on('-o', '--out OUTPUT', 'Specify where to write the results') do |output|
      JsonFilter::Config.instance.out = output
    end
  end.parse!
rescue ArgumentError => e
  puts 'Invalid arguments:'
  puts e.message
  exit 1
end

filter = JsonFilter::Filter.create
filtered = filter.do(JsonFilter::Source.create(JsonFilter::Config.instance.source))
File.open(JsonFilter::Config.instance.out, 'w') { |file| file.write(filtered.to_json)}