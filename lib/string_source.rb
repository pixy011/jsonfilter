#JsonFilter

require 'json'

module JsonFilter
  class StringSource
    def initialize(resource)
      @resource = resource
    end

    def to_json(arg = nil)
      JSON.parse(@resource)
    end
  end
end