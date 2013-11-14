# encoding: utf-8
require 'spec_helper'

describe Smartfocus::Api do

  subject do
    described_class.new(
        server_name: 'emvapi.emv3.com',
        login: 'api_login',
        password: 'api_password',
        key: 'api_key',
        endpoint: 'apimember'
    )
  end

  before do
    subject.stub(:logger).and_return(double("logger").as_null_object)
  end

  it "opens connection successfuly" do
    VCR.use_cassette('opens connection successfuly') do
      subject.open_connection
      expect(subject.connected?).to be(true)
    end
  end

  it "closes connection successfuly" do
    VCR.use_cassette('closes connection successfuly') do
      subject.token = '111token111'
      expect(subject.close_connection).to eq("connection closed")
      expect(subject.connected?).to be(false)
    end
  end

  it "invalidates token properly" do
    subject.token = '111token111'
    expect(subject.invalidate_token!).to eq(nil)
    expect(subject.connected?).to be(false)
  end

  it "deconnects when the endpoint is changed" do
    subject.token = '111token111'
    VCR.use_cassette('deconnects when the endpoint is changed') do
      subject.endpoint = 'apiccmd'
      expect(subject.connected?).to be(false)
    end
  end

  it "returns base_uri" do
    expect(subject.base_uri).to eq("http://#{subject.server_name}/#{subject.endpoint}/services/rest/")
  end

  context 'Attributes' do

    [:server_name, :endpoint, :login, :password, :key, :debug].each do |attribute|

      it "inherites #{attribute} from class" do
        described_class.send("#{attribute}=", "my value")
        expect(described_class.new.send(attribute)).to eq("my value")
      end

      it "does not inherites #{attribute} from class" do
        described_class.send("#{attribute}=", "my value")
        expect(described_class.new(attribute => "another value").send(attribute)).to eq("another value")
      end

    end

  end

  context 'Relation' do

    let(:request) { double("request") }
    let(:relation) { Smartfocus::Relation }

    before do
      Smartfocus::Relation.stub(new: relation)
    end

    [:get, :post].each do |verb|

      it "returns a relation when #{verb} is called" do
        allow(subject).to receive(:build_request).with(verb).and_return(request)
        expect(relation).to receive(:new).with(subject, request)
        expect(subject.send(verb)).to be_a(relation.class)
      end

    end

  end

  context 'Member' do

    it "retrieves member by email successfuly" do
      VCR.use_cassette('retrieves member by email successfuly') do
        subject.token = '111token111'
        result = subject.get.member.get_member_by_email(uri: ['basgys@gmail.com']).call
        expect(result).to eq({
                                 "members"=>{
                                     "member"=>{
                                         "attributes"=>{
                                             "entry"=>[
                                                 {"key"=>"MEMBER_ID", "value"=>"1"},
                                                 {"key"=>"EMAIL", "value"=>"basgys@gmail.com"},
                                                 {"key"=>"ANOTHER_FIELD", "value"=>"another value"}
                                             ]
                                         }
                                     }
                                 },
                                 "responseStatus"=>"success"
                             })
      end
    end

    it "retrieves member by id successfuly" do
      VCR.use_cassette('retrieves member by id successfuly') do
        subject.token = '111token111'
        result = subject.get.member.get_member_by_id(id: 1).call
        expect(result).to eq({
                                 "members"=>{
                                     "member"=>{
                                         "attributes"=>{
                                             "entry"=>[
                                                 {"key"=>"MEMBER_ID", "value"=>"1"},
                                                 {"key"=>"EMAIL", "value"=>"basgys@gmail.com"},
                                                 {"key"=>"ANOTHER_FIELD", "value"=>"another value"}
                                             ]
                                         }
                                     }
                                 },
                                 "responseStatus"=>"success"
                             })
      end
    end

    it "cannot find a member with this email" do
      VCR.use_cassette('cannot find a member with this email') do
        subject.token = '111token111'
        result = subject.get.member.get_member_by_email(uri: ['fake@ema.il']).call
        expect(result).to eq({"members"=>nil, "responseStatus"=>"success"})
      end
    end

  end

  context "Exceptions" do

    it "opens connection with parsing error" do
      VCR.use_cassette('opens connection with parsing error') do
        expect { subject.open_connection }.to raise_error(Smartfocus::MalformedResponse)
      end
    end

    it "reset connection and retry request 3 times when request has timed out" do
      request = double("request")
      allow(request).to receive(:http_verb).and_return(:get)
      allow(request).to receive(:uri).and_return("/fake/uri")
      allow(request).to receive(:parameters).and_return([])
      allow(request).to receive(:body).and_return("")

      allow(subject).to receive(:perform_request).and_raise(Timeout::Error)

      expect(subject).to receive(:perform_request).exactly(3).times
      expect { subject.call(request) }.to raise_error(Timeout::Error)
    end

  end

end