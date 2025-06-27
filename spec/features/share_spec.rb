# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Using the 'Share' dropdown", :js do
  let(:expected_content_type) { 'application/x-research-info-systems' }
  let(:expected_file_name) { 'document.ris' }

  it 'renders email prompt and sends email' do
    visit '/catalog/22090269'
    click_on 'Share'
    click_on 'Email'
    expect(page).to have_content 'Email This'
    fill_in 'Email:', with: 'test@psu.edu'
    fill_in 'Message:', with: 'Message'
    click_on 'Send'
    expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(ActionMailer::Base.deliveries.first.to).to eq ['test@psu.edu']
    expect(ActionMailer::Base.deliveries.first.from).to eq ['noreply@psu.edu']
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'Ethical and Social Issues in the Information Age'
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'Message: Message'
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'http://www.example.com/catalog/22090269'
    expect(ActionMailer::Base.deliveries.first.subject).to include 'PSU Libraries Item Record: Ethical and Social'
  end

  it 'renders RIS file in the dropdown and downloads an RIS of the record' do
    visit '/catalog/22090269'
    click_on 'Share'
    expect(page).to have_link 'RIS file'

    click_on 'RIS file'
    expect(page.response_headers['Content-Disposition']).to include("attachment; filename=\"#{expected_file_name}\"")
    expect(page.response_headers['Content-Type']).to eq(expected_content_type)
  end
end
