# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Using the 'Share' dropdown" do
  let(:expected_content_type) { 'application/x-research-info-systems' }
  let(:expected_file_name) { 'document.ris' }

  it 'renders email prompt and sends email', :js do
    visit '/catalog/22090269'
    click_on 'Share'
    click_on 'Email'
    expect(page).to have_content 'Email This'
    fill_in 'Email:', with: 'test@psu.edu'
    fill_in 'Message:', with: 'Message'
    click_on 'Send'
    expect(page).to have_content 'Email Sent'
    expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(ActionMailer::Base.deliveries.first.to).to eq ['test@psu.edu']
    expect(ActionMailer::Base.deliveries.first.from).to eq ['noreply@psu.edu']
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'Ethical and Social Issues in the Information Age'
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'Message: Message'
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'http://'
    expect(ActionMailer::Base.deliveries.first.body.to_s).to include '/catalog/22090269'
    expect(ActionMailer::Base.deliveries.first.subject).to include 'PSU Libraries Item Record: Ethical and Social'
  end

  it 'renders RIS file in the dropdown', :js do
    visit '/catalog/22090269'
    click_on 'Share'
    expect(page).to have_link 'RIS file'
  end
end
