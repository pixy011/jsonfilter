# JsonFilter

module JsonFilter
  class SimpleFilter
    attr_accessor :errors

    def initialize(filter = Config.instance.filter)
      @filter_source = Source.create(filter)
      @filter = @filter_source.to_json
    end

    def do(data)
      #raise TypeError, "Expecting JsonFilter::*Source" unless data.class.name =~ /^JsonFilter::\w+Source$/
      data = data.to_json if data.class.name != 'Hash'
      @filtered = Hash.new
      @errors = ''
      _recurse(data, @filter, @filtered)
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
            delete = false
            product_level[key] = Crawler.do(data, value) do |args|
              if args[:optional]
                delete = true
              else
                _error(args[:error_message], 'warning')
              end
            end || "<cannot find key #{value} in source data>"
            product_level.delete(key) if delete
          else
            _error("Filter with key #{key} has an unknown format", 'warning')
        end
      end
    end
  end
end