# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search, type: :model, redis: true do
  let(:id) { SecureRandom.hex(10) }
  let(:redis_connection) { Redis.new(url: Settings.redis.sessions.uri) }

  describe '::create' do
    context 'when Redis is working' do
      let(:params) { { q: 'params' } }

      before { described_class.create(id: id, query_params: params) }

      it 'writes a new key/value into Redis as json' do
        expect(redis_connection.get("search:#{id}")).to eq(params.to_json)
      end
    end

    context 'when Redis is down' do
      subject { described_class.create }

      before { allow(described_class).to receive(:new).and_raise(StandardError) }

      it { is_expected.to be_a(described_class::NullSearch) }
    end
  end

  describe '::find' do
    subject { described_class.find(id) }

    context 'when the key does not exist' do
      it { is_expected.to be_nil }
    end

    context 'when the key exists' do
      before { described_class.redis.set(id, 'query_params') }

      it { is_expected.to be_a(described_class) }
    end

    context 'when Redis is down' do
      before { allow(described_class).to receive(:redis).and_raise(StandardError) }

      it { is_expected.to be_a(described_class::NullSearch) }
    end
  end

  describe '::new' do
    its(:id) { is_expected.not_to be_nil }
  end

  describe '#query_params' do
    subject { described_class.new(query_params: params).query_params }

    context 'when nil' do
      let(:params) {}

      it { is_expected.to be_nil }
    end

    context 'when a Hash' do
      let(:params) { { q: 'foo', fl: ['bar'] } }

      it { is_expected.to eq(params) }
    end

    context 'when a parsable json string' do
      let(:params) { { q: 'foo', fl: ['bar'] }.to_json }

      it { is_expected.to eq(JSON.parse(params)) }
    end

    context 'when an unparsable json string' do
      let(:params) { 'you cannot parse this' }

      it { is_expected.to eq(params) }
    end
  end

  describe '#[]' do
    context 'when the attribute exists' do
      subject { described_class.new[:id] }

      it { is_expected.not_to be_nil }
    end

    context 'when the attribute does NOT exist' do
      subject { described_class.new[:foo] }

      it { is_expected.to be_nil }
    end
  end

  describe '#save' do
    let(:params) { { q: 'foo', fl: ['bar'] } }
    let(:search) { described_class.new(query_params: params) }

    before { search.save }

    it 'saves the key/value pair to Redis as a json string with an expiration time' do
      expect(redis_connection.get(search.id)).to eq(params.to_json)
      expect(redis_connection.ttl(search.id)).to be >= Settings.redis.sessions.ttl
    end
  end

  describe described_class::NullSearch do
    its(:anything) { is_expected.to be_nil }
    its(:query_params) { is_expected.to eq({}) }
  end
end
