# JsonFilter

module JsonFilter
  class Filter
    class << self
      def create
        Object.const_get("JsonFilter::#{Config.instance.filter_type.capitalize}Filter").new
      end
    end
  end
end