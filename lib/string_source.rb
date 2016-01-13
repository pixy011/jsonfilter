#JsonFilter

require 'json'

module JsonFilter
  class StringSource
    def initialize(resource)
      @resource = resource
    end

    def to_json(arg = nil)
      JSON.parse(@resource) rescue raise TypeError "Expected JSON formatted string"
    end
  end
end