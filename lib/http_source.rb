# JsonFilter

require 'json'
require 'net/http'

module JsonFilter
  class HttpSource
    def initialize(resource)
      @resource = resource
      @uri = URI(resource)
    end

    def to_json
      JSON.parse(Net::HTTP.get(@uri))
    end
  end
end