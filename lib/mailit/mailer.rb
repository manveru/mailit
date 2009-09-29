module Mailit
  # The Mailer is an abstraction layer for different SMTP clients, it provides
  # #send and #defer_send methods
  #
  # At the time of writing, Net::SMTP and EventMachine::Protocols::SmtpClient are
  # supported, it should be trivial to add support for any other client.
  #
  # The difference between #send and #defer_send depends on the backend, but
  # usually #send will block until the mail was sent while #defer_send does it
  # in the background and allows you to continue execution immediately.
  #
  # @example Usage
  #
  #   mail = Mailit::Mail.new
  #   mail.to = 'test@test.com'
  #   mail.from = 'sender@sender.com'
  #   mail.subject 'Here are some files for you!'
  #   mail.text = 'This is what you see with a plaintext mail reader'
  #   mail.attach('/home/manveru/.vimrc')
  #
  #   # Send and wait until sending finished
  #   Mailit::Mailer.send(mail)
  #
  #   # Send in background thread and continue doing other things
  #   Mailit::Mailer.defer_send(mail)
  #
  # The default Mailer backend is Net::SMTP, you can change the
  # default by including another module into Mailit::mailer
  #
  # @example Using Mailt::Mailer::EventMachine by inclusion
  #
  #   class Mailit::Mailer
  #     include Mailit::Mailer::EventMachine
  #   end
  #
  class Mailer
    OPTIONS = {
      :server    => 'smtp.localhost',
      :port      => 25,
      :domain    => 'localhost',
      :username  => '',
      :password  => 'foo',
      :noop      => false,
      :auth_type => :login, # :plain, :login, :cram_md5
      :starttls  => false,  # only useful for EventMachine::SmtpClient
    }

    def self.send(mail, options = {})
      new.send(mail, options)
    end

    def self.defer_send(mail, options = {})
      new.defer_send(mail, options)
    end

    attr_reader :options

    def initialize(options = {})
      @options = OPTIONS.merge(options)
    end

    def send(mail, override = {})
      require 'net/smtp'
      mailer = override[:mailer] || ::Net::SMTP

      server, port, domain, username, password, auth_type, noop =
        settings(override, :server, :port, :domain, :username, :password, :auth_type, :noop)
      username = mail.from.to_s if username.empty?

      mailer.start(server, port, domain, username, password, auth_type) do |smtp|
        return if noop
        smtp.send_message(mail.to_s, mail.from, mail.to)
      end
    end

    def defer_send(mail, override = {})
      Thread.new{ send(mail, override) }
    end

    private

    def settings(override, *keys)
      options.merge(override).values_at(*keys)
    end

    # Allows you to comfortably use the EventMachine::Protocols::SmtpClient.
    # In order to use it, you have to first include this module into Mailit::Mailer
    module EventMachine
      # This assumes that EventMachine was required and we are inside the
      # EventMachine::run block.
      #
      # Since EM implements some parts of the mail building we'll have to
      # deconstruct our mail a bit.
      # On the upside, it seems like it supports STARTTLS (without certificate
      # options though)
      def self.included(base)
        require 'em/protocols/smtpclient'
        base.module_eval do
          def send(mail, override = {})
            server, port, domain, username, password, auth_type =
              settings(override, :server, :port, :domain, :username, :password, :auth_type)

            mail.construct # prepare headers and body

            em_options = { :port => port, :host => server, :domain => domain,
              :from => mail.from, :to => mail.to, :header => mail.header_string,
              :body => mail.body_string }

            if auth_type
              em_options[:auth] = {
                :type => auth_type, :username => username, :password => password }
            end

            email = EM::Protocols::SmtpClient.send(em_options)
            email.callback &@callback if @callback
            email.errback &@errback if @errback
          end

          def callback(proc=nil, &blk)
            @callback = proc || blk
          end

          def errback(proc=nil, &blk)
            @errback = proc || blk
          end
          
          alias defer_send send
        end
        
      end
    end # module EventMachine
  end # class Mailer
end # module Mailit
