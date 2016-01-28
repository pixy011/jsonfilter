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

    def parse(tag = '<unknown>')

      (json = JSON.parse(_read_http)) rescue raise RuntimeError, "Expected JSON formatted HTTP resource at '#{tag}' for http source"
      if @root == ''
        json
      else
        Parser.do(json, @root) { raise RuntimeError, "Invalid root '#{@root}'"}
      end
    end

  private
    def _read_http
      request = Net::HTTP::Get.new(@uri)
      request.add_field('Content-Type', 'application/json')
      request.basic_auth(Config.instance.http_basic_user, Config.instance.http_basic_pass) unless
          Config.instance.http_basic_user == nil || Config.instance.http_basic_pass == nil

      begin
        res = Net::HTTP.start(@uri.hostname, @uri.port, :use_ssl => @uri.scheme == 'https') do |http|
          http.request(request)
        end
      rescue StandardError => e
        puts 'Http communication failed:'
        puts e.message
        exit 101
      end

      res.body
    end
  end
end