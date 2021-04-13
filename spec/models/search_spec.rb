# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search, type: :model do
  it { is_expected.not_to be_saved }
  it { is_expected.to be_readonly }
end
