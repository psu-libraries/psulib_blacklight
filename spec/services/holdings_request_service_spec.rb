# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HoldingsRequestService do
  let(:args) { '&titleID=24053587' }
  let(:service) { described_class.new(args) }

  describe '#holdings_availability' do
    context 'when there is only one set of ItemInfo in the Sirsi response' do
      let(:response1) { Rails.root.join('spec/fixtures/sirsi_response1.xml').read }
      let(:availability) { "Currently on shelf as of #{Time.now.strftime('%m/%d/%Y %H:%M')}" \
        "\n\nPenn State Altoona:\nCall Number: E909.O24A3 2018, Location: Stacks - General Collection\n" }

      before { allow(Net::HTTP).to receive(:get).and_return(response1) }

      it 'returns a readable string of availability information' do
        expect(service.holdings_availability).to eq availability
      end
    end

    context 'when there are multiple sets of ItemInfo in the Sirsi response' do
      let(:response2) { Rails.root.join('spec/fixtures/sirsi_response2.xml').read }
      let(:availability) { "Currently on shelf as of #{Time.now.strftime('%m/%d/%Y %H:%M')}" \
        "\n\nPenn State Altoona:\nCall Number: E909.O24A3 2018, Location: Stacks - General Collection" \
        "\n\nPenn State Brandywine:\nCall Number: E909.O24A3 2018, Location: Online Content\n\n" \
        "Penn State York:\nCall Number: E909.O24A3 2018, Location: " \
        "\nCall Number: E909.O24A3 2018, Location: \n\nPattee Library and Paterno Library Stacks:" \
        "\nCall Number: E909.O24A3 2018, Location: \nCall Number: E909.O24A3 2018, Location: " \
        "\nCall Number: E909.O24A3 2018, Location: \n\nFollow record link view more available locations" }

      before { allow(Net::HTTP).to receive(:get).and_return(response2) }

      it 'returns a readable string of availability information' do
        expect(service.holdings_availability).to eq availability
      end
    end
  end
end
