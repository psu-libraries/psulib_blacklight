# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:config_builder) { instance_double(BlackcatConfig::Builder) }

  before do
    allow(config_builder).to receive(:readonly_holds?).and_return(true)
    allow(BlackcatConfig::Builder).to receive(:new).and_return(config_builder)
  end

  describe 'blackcat_config' do
    it 'assigns blackcat config' do
      expect(controller.blackcat_config.readonly_holds?).to be true
    end
  end
end
