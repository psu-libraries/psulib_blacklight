#frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Using the email feature in the 'Share' dropdown", type: :feature do
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
     expect(ActionMailer::Base.deliveries.first.from).to eq ["noreply@psu.edu"]
     expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'Ethical and Social Issues in the Information Age'
     expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'Message: Message'
     expect(ActionMailer::Base.deliveries.first.body.to_s).to include 'http://www.example.com/catalog/22090269'
     expect(ActionMailer::Base.deliveries.first.subject).to eq 'PSU Libraries Item Record: Ethical and Social Issues in the Information Age [electronic resource] / by Joseph Migga Kizza'
   end
 end
