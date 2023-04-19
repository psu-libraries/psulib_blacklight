require 'rails_helper'

RSpec.describe SearchBuilder, type: :model do
  describe '#add_all_online_to_query' do
    let(:scope) do
      struct = Struct.new(:blacklight_config)
      struct.new(Blacklight::Configuration.new)
    end

    context "when blacklight_params['add_all_online'] is not present" do
      let(:blacklight_params) { {} }
      let(:solr_parameters) { { fq: ['{!term f=campus_facet tag=campus_facet_single}'] } }

      it 'returns nil' do
        expect(described_class.new(scope)
          .with(blacklight_params)
          .add_all_online_to_query(solr_parameters))
          .to be_nil
      end
    end

    context "when blacklight_params['add_all_online'] is 'true'" do
      let(:blacklight_params) { { 'add_all_online' => 'true' } }
      let(:solr_parameters) { { fq: ['{!term f=campus_facet tag=campus_facet_single}Test Campus'] } }

      it 'returns the campus facet OR all online query' do
        expect(described_class.new(scope)
          .with(blacklight_params)
          .add_all_online_to_query(solr_parameters))
          .to eq "access_facet:Online OR {!term f=campus_facet tag=campus_facet_single v='Test Campus'}"
      end

      context "when there's more than one filter query in the solr parameters" do
        before do
          solr_parameters[:fq] << '{!term f=format}Book'
        end

        it 'returns nil' do
          expect(described_class.new(scope)
            .with(blacklight_params)
            .add_all_online_to_query(solr_parameters))
            .to be_nil
        end
      end

      context 'when the filter query is not campus_facet_single' do
        before do
          solr_parameters[:fq] = ['{!term f=format}Book']
        end

        it 'returns nil' do
          expect(described_class.new(scope)
            .with(blacklight_params)
            .add_all_online_to_query(solr_parameters))
            .to be_nil
        end
      end
    end
  end
end
