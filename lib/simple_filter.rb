# JsonFilter

module JsonFilter
  class SimpleFilter
    attr_accessor :errors

    def initialize(filter = Config.instance.filter)
      @filter_source = Source.create(filter)
      @filter = @filter_source.parse('filter')
    end

    def do(data)
      #raise TypeError, "Expecting JsonFilter::*Source" unless data.class.name =~ /^JsonFilter::\w+Source$/
      data = data.parse('source') if data.class.name != 'Hash'
      @filtered = Hash.new
      @errors = ''
      if @filter.class.name == 'Hash'
        _recurse_object(data, @filter, @filtered)
      elsif @filter.class.name == 'Array'
        _recurse_object(data, @filter, @filtered)
      else
        _error('Root filter object has an unknown format', 'error')
      end

      @filtered
    end

    def has_errors?
      @errors != ''
    end

  private
    def _error(message, level = 'error')
      @errors += "\t[#{level.capitalize}] #{message}\n"
    end

    def _recurse_object(data, filter_level, product_level)
      filter_level.each do |key, value|
        product_level[key] = nil
        case value.class.name
          when 'Hash'
            product_level[key] = Hash.new
            _recurse_object(data, value, product_level[key])
          when 'Array'
            product_level[key] = Array.new
            _recurse_array(data, value, product_level[key])
          when 'String'
            delete = false
            has_error = false
            product_level[key] = Parser.do(data, value) do |args|
              if args[:optional]
                delete = true
              else
                has_error = true
                _error(args[:error_message], 'warning')
              end
            end || (has_error ? "<cannot find key string '#{value}' in source data>" : nil)
            product_level.delete(key) if delete
          else
            _error("Filter with key '#{key}' has an unknown format", 'error')
        end
      end
    end

    def _recurse_array(data, filter_level, product_level)
      filter_level.each do |value|
        newValue = nil
        delete = false

        case value.class.name
          when 'Hash'
            newValue = Hash.new
            _recurse_object(data, value, newValue)
          when 'Array'
            newValue = Array.new
            _recurse_array(data, value, newValue)
          when 'String'

            has_error = false
            newValue = Parser.do(data, value) do |args|
              if args[:optional]
                delete = true
              else
                has_error = true
                _error(args[:error_message], 'warning')
              end || (has_error ? "<cannot find key string '#{value}' in source data>" : nil)
            end
          else
            _error("Filter with key string '#{key}' has an unknown format", 'error')
        end

        product_level << newValue unless delete
      end
    end
  end
end