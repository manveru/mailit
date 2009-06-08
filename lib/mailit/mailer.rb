module Mailit
  # The Mailer is an abstraction layer for different SMTP clients, it provides
  # #send and #defer_send methods
  #
  # At the time of writing, Net::SMTP and EventMachine::SmtpClient are
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
  # The default Mailer backend is Mailit::Mailer::NetSmtp, you can change the
  # default by including another module into Mailit::mailer
  #
  # @example Using Mailt::Mailer::EventMachine by inclusion
  #
  #   class Mailit::Mailer
  #     include Mailit::Mailer::EventMachine
  #   end
  #
  # Another way is to extend an instance of Mailer with the backend you want to
  # use, which will not affect other instances.
  #
  # @example Using Mailit::mailer::EventMachine by extension
  #
  #   mailer = Mailit::Mailer.new
  #   mailer.extend(Mailit::Mailer::EventMachine)
  class Mailer
    OPTIONS = {
      :server    => 'smtp.localhost',
      :port      => 25,
      :domain    => 'localhost',
      :username  => 'foo',
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

    undef :send

    attr_reader :options

    def initialize(options = {})
      @options = OPTIONS.merge(options)
      extend NetSmtp unless respond_to?(:send)
    end

    private

    def settings(override, *keys)
      options.merge(override).values_at(*keys)
    end

    module NetSmtp
      def send(mail, override = {})
        require 'net/smtp'

        server, port, domain, username, password, auth_type =
          settings(override, :server, :port, :domain, :username, :password, :auth_type)

        ::Net::SMTP.start(server, port, domain, username, password, auth_type) do |smtp|
          return if noop
          smtp.send_message(mail.to_s, mail.from, mail.to)
        end
      end

      def defer_send(mail, override = {})
        Thread.new{ send(mail, override) }
      end
    end

    # Allows you to comfortably use the EventMachine::SmtpClient.
    # In order to use it, you have to first include this module into
    # Mailit::Mailer or extend the Mailit::Mailer instance with it.
    module EventMachine

      # This assumes that EventMachine was required and we are inside the
      # EventMachine::run block.
      #
      # Since EM implements some parts of the mail building we'll have to
      # deconstruct our mail a bit.
      # On the upside, it seems like it supports STARTTLS (without certificate
      # options though)
      def send(mail, options = {})
        server, port, domain, username, password, auth_type =
          settings(override, :server, :port, :domain, :username, :password, :auth_type)

        mail.construct # prepare headers and body

        em_options = { :port => port, :host => host, :domain => domain,
          :from => mail.from, :to => mail.to, :header => mail.header_string,
          :body => mail.body_string }

        if auth_type
          em_options[:auth] = {
            :type => auth_type, :username => username, :password => password }
        end

        ::EventMachine::SmtpClient.send(em_options)
      end

      alias defer_send send
    end
  end
end
