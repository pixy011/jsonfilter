#JsonFilter

require 'json'

module JsonFilter
  class StringSource
    def initialize(resource, root)
      @resource = resource
      @root = root
    end

    def to_json(arg = nil)
      (json = JSON.parse(@resource)) rescue raise RuntimeError, 'Expected JSON formatted string'
      if @root == ''
        json
      else
        Crawler.do(json, @root) { raise RuntimeError, "Invalid root #{@root}"}
      end
    end
  end
end