require 'spec/helper'

class MockSMTP
  INSTANCES = []

  def self.start(*args, &block)
    INSTANCES << new(*args, &block)
  end

  attr_reader :start_args, :result, :send_message_args

  def initialize(*args, &block)
    @start_args = args
    yield(self)
  end

  def send_message(*args)
    @send_message_args = args
  end
end

Mailit::Mail::OPTIONS[:message_id] = lambda{|mail| '1234' }

describe Mailit::Mailer do
  it 'sends a mail' do
    mail = Mailit::Mail.new(
      :to => 'test@example.com',
      :from => 'sender@example.com',
      :subject => 'Here are some files for you!',
      :text => 'Some text about that')

    mailer = Mailit::Mailer.new

    mailer.send(mail, :server => 'smtp.example.com', :port => 25,
                :domain => 'example.com', :password => 'foo',
                :mailer => MockSMTP)

    mock = MockSMTP::INSTANCES.last
    mock.start_args.should == [
      'smtp.example.com', 25,
      'example.com',
      'sender@example.com',
      'foo',
      :login
    ]
    mock.send_message_args.should == [mail.to_s, mail.from, mail.to]
  end
end
