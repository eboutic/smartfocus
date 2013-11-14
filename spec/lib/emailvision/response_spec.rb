# encoding: utf-8
require 'spec_helper'

describe Smartfocus::Response do

  let(:response) { double("response") }
  let(:logger) { double("logger") }

  subject { described_class.new(response, logger) }

  before(:each) do
    allow(logger).to receive(:receive)
  end

  context "Exceptions" do

    let(:request_error) { Smartfocus::RequestError }
    let(:session_error) { Smartfocus::SessionError }

    before(:each) do
      # Smartfocus doc:
      # for any Exception or error during the processing of an API call,
      # a 500 HTTP error code is then returned to the requester service.
      # If all OK, a “OK” HTTP code 200 is returned
      allow(subject).to receive(:http_code).and_return(500)
    end

    it "raises a request error when the status code is 500" do
      allow(subject).to receive(:content).and_return('')
      expect { subject.extract }.to raise_error(request_error)
    end

    it "raises a session error when session has expired" do
      allow(subject).to receive(:content).and_return('...Your session has expired...')

      expect { subject.extract }.to raise_error(session_error)
    end

    it "raises a session error when the maximum number of connection allowed per session has been reached" do
      allow(subject).to receive(:content).and_return('...The maximum number of connection allowed per session has been reached...')

      expect { subject.extract }.to raise_error(session_error)
    end

  end

end