# JsonFilter

module JsonFilter
  class Crawler
    class << self
      def do(data, key_string, &block)
        if key_string[0] == '\'' && key_string[-1] == '\''
          key_string[1..-2]
        else
          optional = key_string[0] == '?'
          key_string = key_string[1..-1] if optional
          _key_string(data, key_string) do |args|
            args[:optional] = optional
            yield args
          end
        end
      end

    private
      def _key_string(data, key_string)
        keys = key_string.split(/(?<!\\)\./)
        cursor = data
        keys.each do |key|
          index = nil
          if key =~ /.+\[\d+\]$/
            index = /\[(\d+)\]$/.match(key)[1].to_i
            key = /(.+)\[\d+\]$/.match(key)[1]
          end
          if cursor == nil
            yield({:error_message => "Key '#{key}' in key string '#{key_string}' does not exist. Parent must be empty.#{_id_iteration(data)}"})
            return nil
          elsif cursor.class.name != 'Hash'
            yield({:error_message => "Non-object while crawling key '#{key_string}' at '#{key}'#{_id_iteration(data)}"})
            return nil
          elsif cursor.has_key?(key)
            cursor = cursor[key]
          else
            yield({:error_message => "Cannot crawl key string '#{key_string}' at '#{key}'#{_id_iteration(data)}"})
            return nil
          end
          if index != nil && cursor.class.name == 'Array'
            if cursor[index] == nil
              yield({:error_message => "Index '#{key}'[#{index}] in key string '#{key_string}' is out of bound#{_id_iteration(data)}"})
              return nil
            end
            cursor = cursor[index]
          end
        end

        cursor
      end

      def _id_iteration(data)
        if Config.instance.iteration_id
          error = false
          iteration_id = self.do(data, Config.instance.iteration_id) do |args|
            error = true
          end

          return error ? "[Error while crawling #{Config.instance.iteration_id}]" : "[#{iteration_id}]"
        end

        ''
      end
    end
  end
end