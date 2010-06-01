module Mailit
  module Mime
    module_function

    def type_for(filename)
      detect_handler unless defined?(@mime_handler)
      send(@mime_handler, filename)
    end

    def detect_handler
      try_require('rubygems')

      if try_require('mime/types')
        @mime_handler = :from_mime_types
      elsif try_require('rack') and try_require('rack/mime')
        @mime_handler = :from_rack
      else
        require 'webrick/httputils'
        @webrick_types = WEBrick::HTTPUtils::DefaultMimeTypes.dup
        try_extend_webrick('/etc/mime.types')
        @mime_handler = :from_webrick
      end
    end

    def from_mime_types(filename)
      MIME::Types.type_for(filename) || 'application/octet-stream'
    end

    def from_rack(filename)
      Rack::Mime.mime_type(File.extname(filename))
    end

    def from_webrick(filename)
      WEBrick::HTTPUtils.mime_type(filename, @webrick_types)
    end

    def try_extend_webrick(file)
      hash = WEBrick::HTTPUtils.load_mime_types(file)
      @webrick_types.merge!(hash)
    rescue
    end

    def try_require(lib)
      require lib
      true
    rescue LoadError
    end
  end
end
