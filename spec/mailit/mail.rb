require 'spec/helper'

# The specs are translated from the Test::Unit tests of MailFactory.
#
# TODO:
# * test_attach_as
# * test_email

describe Mailit::Mail do
  should 'set and get headers' do
    mail = Mailit::Mail.new

    mail.set_header('arbitrary', 'some value')
    mail.get_header('arbitrary').should == ['some value']

    mail.set_header('arbitrary-header', 'some _ value')
    mail.get_header('arbitrary-header').should == ['some _ value']
  end

  should 'generate valid boundaries' do
    50.times do
      boundary = Mailit::Mail.generate_boundary
      boundary.should =~ /^----=_NextPart_[a-zA-Z0-9_.]{25}$/
    end
  end

  should 'make mail with recipient' do
    mail = Mailit::Mail.new

    mail.to = 'test@test.com'
    mail.to.should == 'test@test.com'

    mail.to = 'test@test2.com'
    mail.to.should == 'test@test2.com'

    mail.headers.size.should == 1 # make sure the previous was deleted
  end

  should 'make mail with sender' do
    mail = Mailit::Mail.new

    mail.from = 'test@test.com'
    mail.from.should == 'test@test.com'

    mail.from = 'test@test2.com'
    mail.from.should == 'test@test2.com'

    mail.headers.size.should == 1 # make sure the previous was deleted
  end

  should 'set correct subject' do
    mail = Mailit::Mail.new

    mail.subject = 'Test Subject'
    mail.subject.should == '=?utf-8?Q?Test_Subject?='

    mail.subject = 'A Different Subject'
    mail.subject.should == '=?utf-8?Q?A_Different_Subject?='

    mail.headers.size.should == 1 # make sure the previous was deleted
  end

  should 'use quoted printable with instruction' do
    mail = Mailit::Mail.new

    mail.to = 'test@test.com'
    mail.from = 'test@othertest.com'
		mail.subject = "My email subject has a ? in it and also an = and a _ too... Also some non-quoted junk ()!@\#\{\$\%\}"
    mail.text = "This is a test message with\na few\n\nlines."

    mail.subject.should == "=?utf-8?Q?My_email_subject_has_a_=3F_in_it_and_also_an_=3D_and_a_=5F_too..._Also_some_non-quoted_junk_()!@\#\{\$\%\}?="
  end

  should 'use subject quoting for scandinavian string' do
    mail = Mailit::Mail.new

    mail.to = "test@test.com"
    mail.from = "test@othertest.com"
    # Three a with dots and three o with dots.
    mail.subject = "\303\244\303\244\303\244\303\266\303\266\303\266"
    mail.text = "This is a test message with\na few\n\nlines."

    mail.subject.should == "=?utf-8?Q?=C3=A4=C3=A4=C3=A4=C3=B6=C3=B6=C3=B6?="
  end

  should 'use subject quoting for utf-8 string' do
    mail = Mailit::Mail.new

    mail.to = "test@test.com"
    mail.from = "test@othertest.com"
    mail.subject = "My email subject has a Ã which is utf8."
    mail.text = "This is a test message with\na few\n\nlines."

    mail.subject.should == "=?utf-8?Q?My_email_subject_has_a_=C3=83_which_is_utf8.?="
  end

  should 'encode html as quoted printable' do
    mail = Mailit::Mail.new

    mail.to = "test@test.com"
    mail.from = "test@othertest.com"
    mail.subject = "some html"
    mail.html = "<a href=\"http://google.com\">click here</a>"

    mail.to_s.should.include('<a href=3D"http://google.com">click here</a>')
  end
end
