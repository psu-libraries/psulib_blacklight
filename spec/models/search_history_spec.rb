# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchHistory, type: :model, redis: true do
  let(:session_id) { SecureRandom.hex(10) }
  let(:redis_connection) { Redis.new(url: Settings.redis.sessions.uri) }

  describe '::find_or_initialize' do
    subject { described_class.find_or_initialize(session_id) }

    context 'when the session id does not exist in Redis' do
      its(:search_ids) { is_expected.to be_empty }
    end

    context 'when the session id exists in Redis' do
      let(:search_id) { SecureRandom.hex(10) }

      before { redis_connection.lpush("searchhistory:#{session_id}", search_id) }

      its(:search_ids) { is_expected.to eq([search_id]) }
    end

    context 'when Redis is down' do
      before { allow(described_class).to receive(:redis).and_raise(StandardError) }

      it { is_expected.to be_a(described_class::NullHistory) }
    end
  end

  describe '#searches' do
    subject(:history) { described_class.new(id: session_id) }

    context 'when all searches exist' do
      let(:search1) { Search.create }
      let(:search2) { Search.create }

      before do
        redis_connection.lpush(history.id, search1.id)
        redis_connection.lpush(history.id, search2.id)
      end

      specify do
        expect(history.searches.map(&:id)).to contain_exactly(search1.id, search2.id)
      end
    end

    context 'when one search has expired or does not exist' do
      let(:search1) { Search.create }
      let(:search2) { Search.new }

      before do
        redis_connection.lpush(history.id, search1.id)
        redis_connection.lpush(history.id, search2.id)
      end

      specify do
        expect(history.searches.map(&:id)).to contain_exactly(search1.id)
      end
    end
  end

  describe '#add' do
    let(:history) { described_class.new(id: session_id) }

    context 'when the number of searches is below the limit' do
      it 'adds the search id and sets the expiration value' do
        expect(history.search_ids).to be_empty
        search = Search.create
        history.add(search)
        expect(history.search_ids).to contain_exactly(search.id)
        expect(redis_connection.ttl(history.id)).to be <= Settings.redis.sessions.ttl
      end
    end

    context 'when the new search exceeds the limit' do
      before do
        Settings.search_history_window = 5
        5.times { history.add(Search.create) }
      end

      it 'adds the new search id and truncates the list' do
        expect(history.search_ids.count).to eq(5)
        search = Search.create
        history.add(search)
        expect(history.search_ids.count).to eq(5)
        expect(history.search_ids.first).to eq(search.id)
        expect(redis_connection.ttl(history.id)).to be <= Settings.redis.sessions.ttl
      end
    end
  end

  describe described_class::NullHistory do
    its(:anything) { is_expected.to be_nil }
    its(:searches) { is_expected.to eq([]) }
  end
end
