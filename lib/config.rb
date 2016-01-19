# JsonFilter

require 'singleton'

module JsonFilter
  class Config
    include Singleton

    def initialize
      @config = {
          :filter => '',
          :source => '',
          :out => './filtered.json',
          :root => '',
          :iteration_id => nil,
          :pretty => false,
          :http_basic_user => nil,
          :http_basic_pass => nil,

          #Internal
          :filter_type => 'simple'
      }
    end

    def method_missing(key, *value)
      updating = key[-1] == '='
      key = (updating ? key[0..-2] : key).to_sym
      raise StandardError, "Unknown configuration key '#{key}'" unless @config.has_key?(key)
      if updating
        @config[key] = value[0]
      else
        @config[key]
      end
    end
  end
end