# JsonFilter

require 'json'

module JsonFilter
  class FileSource
    def initialize(resource, root)
      @resource = resource
      @root = root
    end

    def parse(tag = '<unknown>')
      (json = JSON.parse(File.read(@resource))) rescue raise RuntimeError, "Expected JSON formatted file at '#{tag}' for file source"
      if @root == ''
        json
      else
        Parser.do(json, @root) { raise RuntimeError, "Invalid root ''#{@root}''" }
      end
    end
  end
end