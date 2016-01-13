# JsonFilter

require 'singleton'

module JsonFilter
  class Config
    def initialize()
      @config = {
          :source => '',

      }
    end

    def method_missing(key, *value)
      updating = key[-1] == '='
      key = (updating ? key[0..-2] : key).to_sym()
      raise StandardError, "Unknown configuration key '#{key}'" unless @config.has_key?(key)
      if updating
        @config[key] = value[0]
      else
        @config[key]
      end
    end
  end
end