# JsonFilter

module JsonFilter
  class Crawler
    class << self
      def do(data, key_string, &block)
        if key_string[0] == '|' && key_string[-1] == '|'
          _interpolate_string(data, key_string[1..-2])
        elsif key_string == ''
          ''
        else
          optional = key_string[0] == '?'
          key_string = key_string[1..-1] if optional
          _key_string(data, key_string) do |args|
            args[:optional] = optional
            yield args if block_given?
          end
        end
      end

    private
      def _construct_array(data, descriptor)
        array = Array.new

        if descriptor[0] == '\''
          filter = SimpleFilter.new("{#{descriptor.gsub('\'', '"')}}")
          data.each do |item|
            array << filter.do(item)
          end
        else
          data.each do |item|
              array << self.do(item, descriptor) || "Error crawling '#{descriptor}' when constructing array"
          end
        end

        array
      end

      def _interpolate_string(data, string)
        while string =~ /\{=.+\}/
          key_string = /\{=(.+)\}/.match(string)[1]
          string.sub!(/\{=#{key_string}\}/, self.do(data, key_string))
        end

        string
      end

      def _key_string(data, key_string)
        keys = _tokenize(key_string)
        cursor = data
        keys.each do |key|
          index = nil
          construct_array_descriptor = nil
          if key =~ /.+\[\d+\]$/
            index = /\[(\d+)\]$/.match(key)[1].to_i
            key = /(.+)\[\d+\]$/.match(key)[1]
          end
          if key =~ /.+\{.+\}$/
            construct_array_descriptor = /.+\{(.+)\}$/.match(key)[1]
            key = /(.+)\{.+\}$/.match(key)[1]
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

          begin
            return _construct_array(cursor, construct_array_descriptor) unless construct_array_descriptor == nil
          rescue RuntimeError => e
            e.message << " at key '#{key}' of '#{key_string}'"
            raise e
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

      def _tokenize(key_string)
        state = {
            :action => 'search-dot',
            :start => 0,
            :depth => 0,
            :tokens => Array.new
        }
         for i in 0..key_string.size
           if key_string[i] == '{'
             state[:action] = 'skipping'
             state[:depth] += 1
           end
           state[:depth] -= 1 if state[:action] == 'skipping' && key_string[i] == '}'
           state[:action] = 'search-dot' if state[:depth] == 0

           if state[:action] == 'search-dot' && key_string[i] == '.'
             state[:tokens] << key_string[state[:start]..i - 1]
             state[:start] = i + 1
           end
         end
        state[:tokens] << key_string[state[:start]..-1]

        state[:tokens]
      end
    end
  end
end