require 'spec_helper'
require 'json'

# define an utility metod
class Array
   def except(*value)
     self - value
   end
end

describe JSONValidate do
  it 'should have a version number' do
    expect(JSONValidate::VERSION).not_to be_nil
  end

  describe "#validate" do
    it 'should not raise error for valid object types' do
      json = JSON.parse('{"a":1, "b":"hoge", "c":{"c1":1}, "d":[1,2,3], "e":true, "f":false, "g":null}')
      expect{
        JSONValidate.validate(json, {a: Fixnum, b: String, c: Hash, d: Array, e: TrueClass, f: FalseClass, g: NilClass })
      }.not_to raise_error
    end

    # examples for type unmatch
    types = [Fixnum, String, Hash, Array, TrueClass, FalseClass, NilClass]
    sample_values = {
      '1' => Fixnum,
      '"hoge"' => String,
      '{"c1":1}' => Hash,
      '[1,2,3]' => Array,
      'true' => TrueClass,
      'false' => FalseClass,
      'null' => NilClass}
    sample_values.each do |value, type|
      json = JSON.parse('{"a":'+value+'}')
      types.except(type).each do |wrong_type|
        it "should raise error for #{value} if #{wrong_type} is the expected type" do
          expect{ JSONValidate.validate(json, {a: wrong_type}) }.to raise_error
        end
      end
    end

    it "should raise error for missing variable" do
      json = JSON.parse('{"a": "hoge"}')
      expect{ JSONValidate.validate(json, {a: String, b: String}) }.to raise_error
    end

    it "should handle nested hash properly" do
      json = JSON.parse('{"a": {"b": "hoge", "c": {"d": "foo"}}, "e": "bar"}')
      expect{ JSONValidate.validate(json, {a: {b: String, c: {d: String}}, e: String}) }.not_to raise_error
      expect{ JSONValidate.validate(json, {a: {b: String, c: {d: Fixnum}}, e: String}) }.to raise_error
    end

    it "should validate all items in array" do
      json = JSON.parse('["a", "b", "c", "d"]')
      expect{ JSONValidate.validate(json, [String]) }.not_to raise_error
      expect{ JSONValidate.validate(json, [Fixnum]) }.to raise_error

      json = JSON.parse('["a", "b", "c", 1]')
      expect{ JSONValidate.validate(json, [String]) }.to raise_error(JSONValidate::ValidationError, /\/\[3\]/)

      json = JSON.parse('[{"a": 1, "b": "hoge"}, {"a": 2, "b": "foo"}]')
      expect{ JSONValidate.validate(json, [{a: Fixnum, b: String}]) }.not_to raise_error

      json = JSON.parse('[{"a": 1, "b": "hoge"}, {"a": 2, "b": 3}]')
      expect{ JSONValidate.validate(json, [{a: Fixnum, b: String}]) }.to raise_error(JSONValidate::ValidationError, /\/\[1\]\/b/)

      json = JSON.parse('[{"a": 1, "b": "hoge"}, {"a": 2, "b": "foo"}, {"a": 3}]')
      expect{ JSONValidate.validate(json, [{a: Fixnum, b: String}]) }.to raise_error(JSONValidate::ValidationError, /\/\[2\]/)
    end

    it "should validate string by Regexp" do
      json = JSON.parse('["abc", "aa", "b", "cccc"]')
      expect{ JSONValidate.validate(json, [/[abc]+/])}.not_to raise_error

      json = JSON.parse('["abc", "AA", "b", "cccc"]')
      expect{ JSONValidate.validate(json, [/[abc]+/])}.to raise_error(JSONValidate::ValidationError, /\/\[1\]/)
    end
  end

  describe "Hash#validate" do
    it 'should add an instance method #validate to Hash' do
      expect(Hash.new).to respond_to(:validate)
    end

    it "can be invoked via hash decoded from JSON" do
      json = JSON.parse('{"a": 1, "b": "hoge"}')
      expect{ json.validate{ {a: Fixnum, b: String} } }.not_to raise_error
      expect{ json.validate{ {a: Fixnum, b: Fixnum} } }.to raise_error(JSONValidate::ValidationError, /\/b/)
    end
  end

  describe "Array#validate" do
    it 'should add an instance method #validate to Array' do
      expect(Array.new).to respond_to(:validate)
    end

    it "can be invoked via array decoded from JSON" do
      json = JSON.parse('[{"id": 1}, {"id": 2}, {"id": 3}]')
      expect{ json.validate{ [{id: Fixnum}] } }.not_to raise_error
      expect{ json.validate{ [{id: String}] } }.to raise_error(JSONValidate::ValidationError, /\/\[0\]\/id/)
    end
  end

end
