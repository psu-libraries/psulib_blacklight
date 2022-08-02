# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Chinese, Japanese, Korean searches', type: :feature do
  it 'returns the same result for interchangeable traditional and simplified chinese searches' do
    # Traditional: 中國文學史 | Simplified: 中国文学史
    visit "/?search_field=all_fields&q=#{CGI.escape('中國文學史')}"
    expect(page).to have_link('中国文学史 / 袁行霈主编')
    visit "/?search_field=all_fields&q=#{CGI.escape('中国文学史')}"
    expect(page).to have_link('中国文学史 / 袁行霈主编')
  end
end
