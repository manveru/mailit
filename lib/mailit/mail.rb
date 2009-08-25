require 'time'
require 'pathname'
require 'enumerator' unless 'String'.respond_to?(:enum_for)

module Mailit

  # = Overview:
  #
  # A simple to use class to generate RFC compliant MIME email.
  #
  # MailIt is a fork of MailFactory and provides a mostly identical API but has
  # been cleaned up, simplified, and made compliant to common Ruby idioms.
  #
  # Copyright (c) 2005-2008 David Powers.
  # Copyright (c) 2009      Michael Fellinger.
  #
  # This program is free software. You can re-distribute and/or
  # modify this program under the same terms as Ruby itself.
  #
  # = Usage:
  #
  #   require 'net/smtp'
  #   require 'mailit'
  #
  #   mail = Mailit::Mail.new
  #   mail.to = 'test@test.com'
  #   mail.from = 'sender@sender.com'
  #   mail.subject 'Here are some files for you!'
  #   mail.text = 'This is what people with plain text mail readers will see'
  #   mail.html = "A little something <b>special</b> for people with HTML readers'
  #   mail.attach('/etc/fstab')
  #   mail.attach('/home/manveru/.vimrc')
  #
  #   server = 'smtp1.testmailer.com'
  #   port = 25
  #   domain = 'mail.from.domain'
  #   password = 'foo'
  #
  #   Net::SMTP.start(server, port, domain, mail.from, password, :cram_md5) do |smtp|
  #     smtp.send_message(mail.to_s, mail.from, mail.to)
  #   end
  #
  # = Todo:
  #
  # * MailFactory has a method_missing that handles getting and setting of
  #   arbitrary headers.
  #   I went for the less magical #[] and #[]= methods.
  #   Maybe someone can add the MailFactory behaviour.
  class Mail
    VERSION = '2009.03.02'

    BOUNDARY_CHARS = [*'a'..'z'] + [*'A'..'Z'] + [*'0'..'9'] + ['.', '_']
    BOUNDARY_PREFIX = "----=_NextPart_"

    # body_boundary, encoding
    BODY_BOUNDARY = "--%s\r\nContent-Type: %s\r\nContent-Transfer-Encoding: %s"

    # attachment_boundary, mimetype, filename, filename
    ATTACHMENT_BOUNDARY = "--%s\r\nContent-Type: %s; name=%p\r\nContent-Transfer-Encoding: base64\r\nContent-Disposition: inline; filename=%p"

    HTML_BODY = <<BODY.strip
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=%s">
  </head>
  <body bgcolor="#ffffff" text="#000000">
  %s
  </body>
</html>
BODY

    OPTIONS = {
      :date => true,
      :message_id => lambda{|mail|
        time = Time.now
        domain = mail['from'].first.to_s.split('@').last || 'localhost'
        message_id = "<%f.%d.%d@%s>" % [time, $$, time.object_id, domain]
      }
    }


    attr_accessor :charset, :text, :html, :attachment_boundary, :body_boundary
    attr_reader :headers, :attachments

    # Create an instance of {Mailit::Mailer}.
    #
    # @option options [String] :to
    # @option options [String] :from
    # @option options [String] :subject
    # @option options [String] :text
    # @option options [String] :html
    # @author manveru
    def initialize(options = {})
      @headers = []
      @attachments = []
      @attachment_boundary = self.class.generate_boundary
      @body_boundary = self.class.generate_boundary
      @charset = 'utf-8'
      @html = @text = nil

      options.each{|key, value| __send__("#{key}=", value) }
    end

    def construct(options = {})
      options = OPTIONS.merge(options)
      time = Time.now

      if message_id = options[:message_id]
        self['Message-ID'] = message_id.call(self) unless self['Message-Id'].any?
      end

      if options[:date]
        self['Date'] = time.rfc2822 unless self['Date'].any?
      end

      if multipart?
        self['MIME-Version'] = '1.0' unless self['MIME-Version'].any?

        unless self['Content-Type'].any?
          if @attachments.any?
            content_type = ('multipart/alternative; boundary=%p' % body_boundary)
          else
            content_type = ('multipart/mixed; boundary=%p' % attachment_boundary)
          end

          self['Content-Type'] = content_type
        end
      end

      "#{header_string}#{body_string}"
    end
    alias to_s construct

    ## Attachments

    def add_attachment(filename, mimetype = nil, headers = nil)
      container = {
        :filename => Pathname.new(filename).basename,
        :mimetype => (mimetype || mime_type_for(filename)),
      }

      add_attachment_common(container, filename, headers)
    end
    alias attach add_attachment

    def add_attachment_as(file, filename, mimetype = nil, headers = nil)
      container = {
        :filename => filename,
        :mimetype => (mimetype || mime_type_for(file))
      }

      add_attachment_common(container, file, headers)
    end
    alias attach_as add_attachment_as

    ## Shortcuts

    def multipart?
      html || attachments.size > 0
    end

    def html=(html)
      @html = HTML_BODY % [charset, html]
    end

    def raw_html=(html)
      @html = html
    end

    def message_id=(id)
      self['Message-ID'] = id
    end

    def send(options = {})
      Mailer.send(self, options)
    end

    def defer_send(options = {})
      Mailer.defer_send(self, options)
    end

    ## Header handling

    def add_header(header, value)
      case header.to_s.downcase
      when /^subject$/i
        value = quoted_printable_with_instruction(value)
      when /^(from|to|bcc|reply-to)$/i
        value = quote_address_if_necessary(value, charset)
      end

      @headers << [header, value]
    end

    def set_header(header, value)
      remove_header(header)
      add_header(header, value)
    end
    alias []= set_header

    def remove_header(header)
      regex = /^#{Regexp.escape(header)}/i

      @headers.reject!{|key, value| key =~ regex }
    end

    def get_header(header)
      regex = /^#{Regexp.escape(header)}/i

      @headers.map{|key, value| value if regex =~ key }.compact
    end
    alias [] get_header

    def header_string
      headers.map{|key,value| "#{key}: #{value}"}.join("\r\n") << "\r\n\r\n"
    end

    MIME_INDICATOR = "This is a multi-part message in MIME format.\r\n\r\n--%s\r\nContent-Type: multipart/alternative; boundary=%p"

    def body_string
      return text unless multipart?

      body = [ MIME_INDICATOR % [attachment_boundary, body_boundary] ]
      body << build_body_boundary("text/plain; charset=#{charset} format=flowed")
      body << "\r\n\r\n" << quote_if_necessary(text, charset)

      if html
        body << build_body_boundary("text/html; charset=#{charset}")
        body << "\r\n\r\n" << quote_if_necessary(html, charset)
      end

      body << "--#{body_boundary}--"

      attachments.each do |attachment|
        body << build_attachment_boundary(attachment)
        body << "\r\n\r\n" << attachment[:attachment]
        body << "\r\n--#{attachment_boundary}--"
      end

      body.join("\r\n\r\n")
    end

    private

    def add_attachment_common(container, file, headers)
      container[:attachment] = file_read(file)
      container[:headers] = headers_prepare(headers)
      self.attachments << container
    end

    def headers_prepare(headers)
      case headers
      when Array
        container[:headers] = headers
      else
        container[:headers] = headers.split(/\r?\n/)
      end
    end

    def quoted_printable_with_instruction(text)
      text = encode_quoted_printable_rfc2047(text)
      "=?#{charset}?Q?#{text}?="
    end

    def quote_if_necessary(text, charset, instruction = false)
      return unless text

      if text.respond_to?(:force_encoding)
        text = text.dup.force_encoding(Encoding::ASCII_8BIT)
      end

      if instruction
        quoted_printable_with_instruction(text)
      else
        encode_quoted_printable_rfc2045(text)
      end
    end

    def quote_address_if_necessary(address, charset)
      case address
      when Array
        address.map{|addr| quote_address_if_necessary(addr, charset) }
      when /^(\S.*)\s+(<.*>)$/
        phrase = $1.gsub(/^['"](.*)['"]$/, '\1')
        address = $2

        phrase = quote_if_necessary(phrase, charset, true)

        "%p %s" % [phrase, address]
      else
        address
      end
    end

    def encode_file(string)
      [string].pack('m')
    end

    def file_read(file)
      case file
      when String, Pathname
        File.open(file.to_s, 'rb') do |io|
          encode_file(io.read)
        end
      else
        encode_file(file.read)
      end
    end

    def encode_quoted_printable_rfc2045(string)
      [string].pack('M').gsub(/\n/, "\r\n").chomp.gsub(/=$/, '')
    end

    def encode_quoted_printable_rfc2047(string)
      string.enum_for(:each_byte).map{|ord|
        if ord < 128 and ord != 61 # 61 is ascii '='
          ord.chr
        else
          '=%X' % ord
        end
      }.join('').chomp.
        gsub(/=$/,'').gsub('?', '=3F').gsub('_', '=5F').gsub(/ /, '_')
    end

    def build_body_boundary(type, encoding = 'quoted-printable')
      BODY_BOUNDARY % [ body_boundary, type, encoding ]
    end

    def build_attachment_boundary(attachment)
      mime, file, headers = attachment.values_at(:mimetype, :filename, :headers)

      boundary = ATTACHMENT_BOUNDARY % [attachment_boundary, mime, file, file]
      boundary << "\r\n%s" % headers.join("\r\n") if headers

      boundary
    end

    # Try to get the
    def mime_type_for(filename, override = nil)
      override || Mime.type_for(filename)
    end

    ## Header shortcuts

    def self.header_accessors(hash)
      hash.each{|k,v| header_accessor(k, v) }
    end

    def self.header_accessor(method, header)
      public
      eval("def %s; self[%p].first; end" % [method, header.to_s])
      eval("def %s=(o); self[%p] = o; end" % [method, header.to_s])
    end

    header_accessors(:reply_to => 'Reply-To', :to => :to, :from => :from,
                     :subject => :subject, :bcc => :bcc)

    def self.generate_boundary(size = 25, chars = BOUNDARY_CHARS)
      char_count = chars.size
      postfix = Array.new(size){
        chars[rand(char_count)]
      }.join

      return "#{BOUNDARY_PREFIX}#{postfix}"
    end
  end
end
