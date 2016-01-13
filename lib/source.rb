# JsonFilter

module JsonFilter
  class Source
    class << self
      def create(resource)
        raise StandardError, "No source provided" if resource == ''
        return HttpSource.new(resource) if resource.start_with('http')
        return FileSource.new(resource) if resource.length < 260 && File.exist?(resource)
        StringSource.new(resource)
      end
    end
  end
end