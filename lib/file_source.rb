# JsonFilter

require 'json'

module JsonFilter
  class FileSource
    def initialize(resource, root)
      @resource = resource
      @root = root
    end

    def to_json(arg = nil)
      (json = JSON.parse(File.read(@resource))) rescue raise RuntimeError, 'Expected JSON formatted file'
      if @root == ''
        json
      else
        Crawler.do(json, @root) { raise RuntimeError, "Invalid root ''#{@root}''" }
      end
    end
  end
end