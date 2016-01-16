# JsonFilter

Dir['./lib/*_source.rb'].each { |rblib| require_relative File.basename(rblib) }

module JsonFilter
  class Source
    class << self
      def create(resource, root = '')
        raise TypeError, "Expecting resource to be String" unless resource.class.name == 'String'
        raise RuntimeError, "No source provided" if resource == ''
        return HttpSource.new(resource, root) if resource.start_with?('http')
        return FileSource.new(resource, root) if resource.length < 260 && File.exist?(resource)
        StringSource.new(resource, root)
      end
    end
  end
end