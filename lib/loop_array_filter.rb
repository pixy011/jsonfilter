# JsonFilter

require_relative 'simple_filter'

module JsonFilter
  class LoopArrayFilter < SimpleFilter
    def do(data)
      raise TypeError, "Expecting JsonFilter::*Source" unless data.class.name =~ /^JsonFilter::\w+Source$/
      @filtered = Array.new
      @errors = ''
      array = data.to_json
      raise RuntimeError, 'Expected the root to be an array' unless array.class.name == 'Array'
      array.each do |item|
        filtered_item = Hash.new
        _recurse(item, @filter, filtered_item)
        @filtered << filtered_item
      end

      @filtered
    end
  end
end
