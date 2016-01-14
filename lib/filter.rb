# JsonFilter

Dir['./lib/*_filter.rb'].each { |rblib| require_relative File.basename(rblib) }

module JsonFilter
  class Filter
    class << self
      def create
        Object.const_get("JsonFilter::#{Config.instance.filter_type.split('_').map(&:capitalize).join('')}Filter").new
      end
    end
  end
end