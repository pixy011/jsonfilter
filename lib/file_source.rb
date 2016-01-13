# JsonFilter

require 'json'

module JsonFilter
  class FileSource
    def initialize(resource)
      @resource = resource
    end

    def to_json(arg = nil)
      JSON.parse(File.read(@resource))
    end
  end
end