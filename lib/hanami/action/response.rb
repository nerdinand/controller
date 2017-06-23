require 'rack'
require 'rack/response'
require 'hanami/utils/kernel'

module Hanami
  class Action
    class Response < ::Rack::Response
      attr_reader :exposures, :format
      attr_accessor :charset

      def initialize(content_type: nil, body: [], status: 200, header: {})
        super(body, status, header.dup)
        set_header("Content-Type", content_type)

        @charset       = ::Rack::MediaType.params(content_type).fetch('charset', nil)
        @exposures     = {}
      end

      def body=(str)
        @length = 0
        @body   = []

        # FIXME: there could be a bug that prevents Content-Length to be sent for files
        if str.is_a?(::Rack::File::Iterator)
          @body = str
        else
          write(str) unless str.nil?
        end
      end

      def format=(args)
        @format, content_type = *args
        content_type = Action::Mime.content_type_with_charset(content_type, charset)
        set_header("Content-Type", content_type)
      end

      def [](key)
        @exposures.fetch(key)
      end

      def []=(key, value)
        @exposures[key] = value
      end

      def set_format(value)
        @format = value
      end
    end
  end
end
