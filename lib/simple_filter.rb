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

  private
    def _crawl(data, key_string)
      keys = key_string.split(/(?<!\\)\./)
      cursor = data
      keys.each_with_index do |key, index|
        if cursor.has_key?(key)
          if index == keys.size - 1
            return cursor[key]
          else
            cursor = cursor[key]
          end
        else
          _error("Cannot crawl key string #{key_string}")
          return nil
        end
      end
    end

    def _error(message)
      @errors += "#{message}\n"
    end

    def _recurse(data, filter_level, product_level)
      filter_level.each do |key, value|
        product_level[key] = nil
        case value.class.name
          when 'Hash'
            product_level[key] = Hash.new
            _recurse(data, value, product_level[key])
          when 'String'
            product_level[key] = _crawl(data, value)
          else
            _error("Filter with key #{key} is invalid")
        end
      end
    end
  end
end