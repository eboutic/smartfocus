# encoding: utf-8
require 'spec_helper'

describe Smartfocus::Request do

  let(:http_verb) { :get }
  let(:token) { 'fake_token' }
  let(:server_name) { 'emvapi.emv3.com' }
  let(:endpoint) { 'apimember' }

  subject { described_class.new(http_verb, token, server_name, endpoint) }

  it "formats uri without options" do
    subject.prepare('/my/uri', {})
    expect(subject.uri).to eq('/my/uri')
  end

  it "formats uri with options" do
    email = 'fake@ema.il'
    something = 'another_param'
    subject.prepare('/my/uri', uri: [email, something])
    expect(subject.uri).to eq("/my/uri/#{token}/#{email}/#{something}")
  end

  it "has an empty body" do
    subject.prepare('/my/uri', {})
    expect(subject.body).to eq('')
  end

  it "has a body" do
    subject.prepare('/my/uri', body: {firstname: 'Bastien'})
    expect(subject.body).to eq('<?xml version="1.0" encoding="UTF-8"?><firstname>Bastien</firstname>')
  end

end