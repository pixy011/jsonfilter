# JsonFilter

module JsonFilter
  class Crawler
    class << self
      def do(data, key_string)
        keys = key_string.split(/(?<!\\)\./)
        cursor = data
        keys.each_with_index do |key, index|
          index = nil
          if key =~ /.+\[\d+\]$/
            index = /\[(\d+)\]$/.match(key)[1].to_i
            key = /(.+)\[\d+\]$/.match(key)[1]
          end
          if cursor.has_key?(key)
            cursor = cursor[key]
          else
            yield({:error_message => "Cannot crawl key string #{key_string}"})
            return nil
          end
          if index != nil && cursor.class.name == 'Array'
            cursor = cursor[index]
          end
        end

        cursor
      end
    end
  end
end