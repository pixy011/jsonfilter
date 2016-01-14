# JsonFilter

module JsonFilter
  class SimpleFilter
    attr_accessor :errors

    def initialize
      @filter_source = Source.create(Config.instance.filter)
      @filter = @filter_source.to_json
    end

    def do(data)
      raise TypeError, "Expecting JsonFilter::*Source" unless data.class.name =~ /^JsonFilter::\w+Source$/
      @filtered = Hash.new
      @errors = ''
      _recurse(data.to_json, @filter, @filtered)
      @filtered
    end

    def has_errors?
      @errors != ''
    end

  private
    def _error(message, level = 'error')
      @errors += "\t[#{level.capitalize}] #{message}\n"
    end

    def _recurse(data, filter_level, product_level)
      filter_level.each do |key, value|
        product_level[key] = nil
        case value.class.name
          when 'Hash'
            product_level[key] = Hash.new
            _recurse(data, value, product_level[key])
          when 'String'
            product_level[key] = Crawler.do(data, value) { |args| _error(args[:error_message], 'warning') } ||
                "<cannot find key #{value} in source data>"
          else
            _error("Filter with key #{key} has an unknown format", 'warning')
        end
      end
    end
  end
end