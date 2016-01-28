#JsonFilter

require 'json'

module JsonFilter
  class StringSource
    def initialize(resource, root)
      @resource = resource
      @root = root
    end

    def parse(tag = '<unknown>')
      (json = JSON.parse(@resource)) rescue raise RuntimeError, "Expected JSON formatted string at '#{tag}' for string source"
      if @root == ''
        json
      else
        Parser.do(json, @root) { raise RuntimeError, "Invalid root '#{@root}'"}
      end
    end
  end
end