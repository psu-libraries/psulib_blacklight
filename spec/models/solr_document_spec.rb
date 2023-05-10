# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  let(:d) { described_class.new(iiif_manifest_ssim: manifest) }
  let(:manifest) { nil }

  describe '#iiif_manifest_url' do
    context "when the document's iiif_manifest_ssim field is nil" do
      it 'returns nil' do
        expect(d.iiif_manifest_url).to be_nil
      end
    end

    context "when the document's iiif_manifest_ssim field contains an empty array" do
      let(:manifest) { [] }

      it 'returns nil' do
        expect(d.iiif_manifest_url).to be_nil
      end
    end

    context "when the document's iiif_manifest_ssim field contains an array containing one string that is not a valid URL" do
      let(:manifest) { ['not a valid URL'] }

      it 'returns the string' do
        expect(d.iiif_manifest_url).to eq 'not a valid URL'
      end
    end

    context "when the document's iiif_manifest_ssim field contains an array containing one valid URL with host cdm17287.contentdm.oclc.org" do
      let(:manifest) { ['https://cdm17287.contentdm.oclc.org/manifest'] }

      it 'returns the URL without making any HTTP requests' do
        expect(d.iiif_manifest_url).to eq 'https://cdm17287.contentdm.oclc.org/manifest'
        expect(Faraday).not_to have_received(:head)
      end
    end

    context "when the document's iiif_manifest_ssim field contains an array containing one valid URL with host digital.libraries.psu.edu" do
      let(:manifest) { ['https://digital.libraries.psu.edu/manifest'] }

      it 'returns the URL without making any HTTP requests' do
        expect(d.iiif_manifest_url).to eq 'https://digital.libraries.psu.edu/manifest'
        expect(Faraday).not_to have_received(:head)
      end
    end

    context "when the document's iiif_manifest_ssim field contains an array containing one valid URL with some other host" do
      let(:manifest) { ['https://someotherhost.edu/manifest'] }
      let(:response) { instance_double Faraday::Response }

      before do
        allow(Faraday).to receive(:head).with('https://someotherhost.edu/manifest').and_return response
      end

      context 'when a head request for the URL returns a 200 response' do
        before { allow(response).to receive(:status).and_return 200 }

        it 'returns the URL' do
          expect(d.iiif_manifest_url).to eq 'https://someotherhost.edu/manifest'
        end
      end

      context 'when a head request for the URL returns a 500 response' do
        before { allow(response).to receive(:status).and_return 500 }

        it 'returns the URL' do
          expect(d.iiif_manifest_url).to eq 'https://someotherhost.edu/manifest'
        end
      end

      context 'when a head request for the URL returns a 301 response' do
        let(:response2) { instance_double Faraday::Response, status: 200 }

        before do
          allow(response).to receive(:status).and_return 301
          allow(response).to receive(:headers).and_return({ location: 'https://yetanotherhost.edu/manifest' })
          allow(Faraday).to receive(:head).with('https://yetanotherhost.edu/manifest').and_return response2
        end

        context "when a head request for the response's location returns a 200 reponse" do
          it "returns the response's location" do
            expect(d.iiif_manifest_url).to eq 'https://yetanotherhost.edu/manifest'
          end
        end
      end

      context 'when a head request for the URL returns a 302 response' do
        let(:response2) { instance_spy Faraday::Response, status: 200 }

        before do
          allow(response).to receive(:status).and_return 302
          allow(response).to receive(:headers).and_return({ location: 'https://yetanotherhost.edu/manifest' })
          allow(Faraday).to receive(:head).with('https://yetanotherhost.edu/manifest').and_return response2
        end

        context "when a head request for the response's location returns a 200 reponse" do
          it "returns the response's location" do
            expect(d.iiif_manifest_url).to eq 'https://yetanotherhost.edu/manifest'
          end
        end
      end

      context 'when a head request for the URL fails to connect' do
        before do
          allow(Faraday).to receive(:head).with('https://someotherhost.edu/manifest').and_raise(Faraday::ConnectionFailed.new(nil))
        end

        it 'returns the URL' do
          expect(d.iiif_manifest_url).to eq 'https://someotherhost.edu/manifest'
        end
      end

      context 'when a head request for the URL times out' do
        before do
          allow(Faraday).to receive(:head).with('https://someotherhost.edu/manifest').and_raise(Faraday::TimeoutError)
        end

        it 'returns the URL' do
          expect(d.iiif_manifest_url).to eq 'https://someotherhost.edu/manifest'
        end
      end
    end
  end
end
