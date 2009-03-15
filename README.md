# Mailit

Mailit is a simple to use library to create and send MIME compliant e-mail with
attachments and various encodings.

This is a fork of MailFactory and provides a mostly identical API but has been
cleaned up, simplified, and made compliant to common Ruby idioms. I would like
to thank David Powers for the original MailFactory, it served me well for many
years.

Copyright (c) 2005-2008 David Powers.
Copyright (c) 2009      Michael Fellinger.

This program is free software. You can re-distribute and/or modify this program
under the same terms as Ruby itself.


## Dependencies

Any Ruby since 1.8.4 should work.
Mailit can use the Rack or Mime::Types libraries to determine the mime-type of
attachments automatically, but they are optional.


## Usage of Mailit::Mail

    require 'net/smtp'
    require 'mailit'

    mail = Mailit::Mail.new
    mail.to = 'test@test.com'
    mail.from = 'sender@sender.com'
    mail.subject 'Here are some files for you!'
    mail.text = 'This is what people with plain text mail readers will see'
    mail.html = "A little something <b>special</b> for people with HTML readers'
    mail.attach('/etc/fstab')
    mail.attach('/home/manveru/.vimrc')

    puts mail


## Usage of Mailit::Mailer

Using the mail variable from above example

    mailer = Mailit::Mailer.new

    mailer.send(mail, :server => 'smtp.example.com', :port => 25,
                :domain => 'example.com', :password => 'foo')


## Todo:
  
MailFactory has a method_missing that handles getting and setting of arbitrary
headers.
I went for the less magical #[] and #[]= methods, maybe someone can add the
MailFactory behaviour.

## Thanks to

* Michael Thompson (AKA:nylon)

  Making mailer work on windows
