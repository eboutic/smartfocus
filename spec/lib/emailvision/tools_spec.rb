# encoding: utf-8
require 'spec_helper'
require 'active_support/time'

describe Smartfocus::Tools do

  subject { described_class }

  context "#sanitize_parameters" do

    let(:parameters) do
      {
        name: "Jean",
        login_count: 44,
        created_at: DateTime.parse("2013-10-11 09:00"),
        updated_at: Time.parse("2013-10-11 09:00"),
        deleted_at: time_with_zone,
        date: Date.parse("1999-10-09"),
        attributes: {
          a: 1,
          b: 2
        }
      }    
    end
    let(:sanitized_parameters) { subject.sanitize_parameters(parameters) }
    let(:time_with_zone) do
      @utc = Time.utc(2013, 10, 11, 13, 0)
      @time_zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      ActiveSupport::TimeWithZone.new(@utc, @time_zone)
    end

    it "sanitizes String parameters" do
      expect(sanitized_parameters[:name]).to eq("Jean")
    end

    it "sanitizes Int parameters" do
      expect(sanitized_parameters[:login_count]).to eq(44)
    end        

    it "sanitizes DateTime parameters" do
      expect(sanitized_parameters[:created_at]).to eq('2013-10-11T09:00:00')
    end

    it "sanitizes Time parameters" do
      expect(sanitized_parameters[:updated_at]).to eq('2013-10-11T09:00:00')
    end

    it "sanitizes ActiveSupport::TimeWithZone parameters" do
      expect(parameters[:deleted_at]).to be_a(ActiveSupport::TimeWithZone)
      expect(sanitized_parameters[:deleted_at]).to eq('2013-10-11T09:00:00')
    end

    it "sanitizes Date parameters" do
      expect(sanitized_parameters[:date]).to eq('09/10/1999')
    end

    it "sanitizes Hash parameters" do
      expect(sanitized_parameters[:attributes]).to eq({a: 1, b: 2})
    end

  end

  context "#r_camelize" do

    let(:parameters) do
      {
        a: "Value a",
        b: "Value b",
        my_hash: {
          value_c: "Value c",
          value_d: "Value d"
        },
        my_array: [
          "e", "f"
        ]
      }    
    end

    it "camelizes parameters" do
      expect(subject.r_camelize(parameters)).to eq({
        a: "Value a",
        b: "Value b",
        myHash: {
          valueC: "Value c",
          valueD: "Value d"
        },
        myArray: [
          "e", "f"
        ]
      })
    end

  end

  context "#to_xml_as_is" do

    let(:parameters) do
      {
        name: "Jean",
        login_count: 44,
        created_at: time_with_zone,
        updated_at: time_with_zone,
        date: Date.parse("1999-10-09"),
        attributes: {
          a: 1,
          b: 2
        }
      }    
    end
    let(:time_with_zone) do
      @utc = Time.utc(2013, 10, 11, 13, 0)
      @time_zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      ActiveSupport::TimeWithZone.new(@utc, @time_zone)
    end    

    it "transform parameters to XML" do
      expect(subject.to_xml_as_is(parameters)).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><name>Jean</name><login_count>44</login_count><created_at>2013-10-11 09:00:00 -0400</created_at><updated_at>2013-10-11 09:00:00 -0400</updated_at><date>1999-10-09</date><attributes><a>1</a><b>2</b></attributes>")
    end

    it "return an empty string if the argument is empty" do
      expect(subject.to_xml_as_is([])).to eq("")
    end

    it "return an empty string if the argument is nil" do
      expect(subject.to_xml_as_is(nil)).to eq("")
    end    

  end

end