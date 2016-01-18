# JsonFilter

require 'json'
require 'net/http'

module JsonFilter
  class HttpSource
    def initialize(resource, root)
      @resource = resource
      @uri = URI(resource)
      @root = root
    end

    def to_json
      (json = JSON.parse(Net::HTTP.get(@uri))) rescue raise RuntimeError, 'Expected JSON formatted HTTP resource'
      if @root == ''
        json
      else
        Crawler.do(json, @root) { raise RuntimeError, "Invalid root #{@root}"}
      end
    end
  end
end