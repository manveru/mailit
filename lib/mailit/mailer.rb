require 'net/smtp'

module Mailit

  # = Usage:
  #
  #   mail = Mailit::Mail.new
  #   mail.to = 'test@test.com'
  #   mail.from = 'sender@sender.com'
  #   mail.subject 'Here are some files for you!'
  #   mail.text = 'This is what <%= person %> with plain text mail readers will see'
  #
  #   person = 'manveru'
  #
  #   mailer = Mailit::Mailer.new
  #
  #   # Use erb to evaluate the text body, but don't send
  #   mailer.render_send(mail, :noop => true, :binding => binding)
  #
  #   # Use erb to evaluate the text body and send
  #   mailer.render_send(mail, :binding => binding)
  #
  #   # Send without interpolation
  #   mailer.send(mail)
  class Mailer
    OPTIONS = {
      :server => 'smtp.localhost',
      :port => 25,
      :domain => 'localhost',
      :username => 'foo',
      :password => 'foo',
      :engine => :erb,
      :noop => false,
      :binding => nil,
      :mailer => Net::SMTP,
      :auth_type => :login, # :plain, :login, :cram_md5
    }

    attr_reader :options

    # Create an instance of {Mailit::Mailer}
    #
    # @option options :server   ('smtp.localhost')
    # @option options :port     (25)
    # @option options :domain   ('localhost')
    # @option options :password ('foo')
    # @option options :engine   (:erb) interpolate the mail.text
    # @option options :noop     (false) won't send mail if true
    # @option options :binding  (nil) must be provided if engine is :erb
    # @author manveru
    def initialize(options = {})
      @options = OPTIONS.merge(options)
    end

    # @param [Mailit::Mail] mail instance of a Mail
    # @option override :server   ('smtp.localhost')
    # @option override :port     (25)
    # @option override :domain   ('localhost')
    # @option override :password ('foo')
    # @option override :noop     (false) won't send mail if true
    # @option override :engine   (:erb) interpolate the mail.text
    # @option override :binding  (nil) must be provided
    # @see Mailer#send
    # @author manveru
    def render_send(mail, override = {})
      mail = mail.clone
      engine, binding, noop = settings(override, :engine, :binding, :noop)

      case engine
      when :erb
        require 'erb'
        mail.text = ERB.new(mail.text).render(binding)
      end

      send(mail)
    end

    # @param mail [Mailit::Mail]
    # @option override :server   ('smtp.localhost')
    # @option override :port     (25)
    # @option override :domain   ('localhost')
    # @option override :password ('foo')
    # @option override :noop     (false) connect to server but don't send
    # @author manveru
    def send(mail, override = {})
      # start options
      server, port, domain, username, password, auth_type =
        settings(override, :server, :port, :domain, :username, :password, :auth_type)

      noop, mailer = settings(override, :noop, :mailer)

      mailer.start(server, port, domain, username, password, auth_type) do |smtp|
        return if noop
        smtp.send_message(mail.to_s, mail.from, mail.to)
      end
    end

    def defer_send(mail, override = {})
      Thread.new{ send(mail, override) }
    end

    private

    # @param [Hash] override
    # @return [Hash]
    # @author manveru
    def settings(override, *keys)
      options.merge(override).values_at(*keys)
    end
  end
end
