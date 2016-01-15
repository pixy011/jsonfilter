# JsonFilter

module JsonFilter
  class Crawler
    class << self
      def do(data, key_string)
        keys = key_string.split(/(?<!\\)\./)
        cursor = data
        if (data['key'] == 'VS-58')
          test = 1
        end
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

    private
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