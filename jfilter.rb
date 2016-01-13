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
    options.on('-s', '--source', 'Specify the source data in JSON format. Source can be either a URL to an HTTP resource, a path to a local file or a JSON formatted string') do |source|
      raise ArgumentError, 'Source cannot be empty' if source == '' || source == nil
      JsonFilter::Config.instance.source = source
    end
  end
rescue ArgumentError => e
  puts 'Invalid arguments:'
  puts e.message
  exit 1
end