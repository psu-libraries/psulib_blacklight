# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query Limits' do
  context 'when search volume exceeds limit' do
    context 'when on the internal solr instance' do
      before do
        page.driver.header 'X-Forwarded-For', '10.0.0.1'
      end

      context 'when LIMIT_INT_QUERIES is false' do
        context 'when LIMIT_EXT_QUERIES is false' do
          before do
            ENV['LIMIT_INT_QUERIES'] = 'false'
            ENV['LIMIT_EXT_QUERIES'] = 'false'
          end

          after do
            ENV['LIMIT_INT_QUERIES'] = nil
            ENV['LIMIT_EXT_QUERIES'] = nil
          end

          it 'does not require auth for multiple queries' do
            visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
                  '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
            expect(page).to have_current_path('/?f%5Baccess_facet%5D%5B%5D=In+the+Library&f%5B' \
                                              'campus_facet%5D%5B%5D=University+Park&f%5Bformat%5D%5B%5D' \
                                              '=Book&f%5Bup_library_facet%5D%5B%5D=Pattee+Library+and+' \
                                              'Paterno+Library+Stacks')
          end
        end

        context 'when LIMIT_EXT_QUERIES is true' do
          before do
            ENV['LIMIT_INT_QUERIES'] = 'false'
            ENV['LIMIT_EXT_QUERIES'] = 'true'
          end

          after do
            ENV['LIMIT_INT_QUERIES'] = nil
            ENV['LIMIT_EXT_QUERIES'] = nil
          end

          it 'does not require auth for multiple queries' do
            visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
                  '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
            expect(page).to have_current_path('/?f%5Baccess_facet%5D%5B%5D=In+the+Library&f%5B' \
                                              'campus_facet%5D%5B%5D=University+Park&f%5Bformat%5D%5B%5D' \
                                              '=Book&f%5Bup_library_facet%5D%5B%5D=Pattee+Library+and+' \
                                              'Paterno+Library+Stacks')
          end
        end
      end

      context 'when LIMIT_INT_QUERIES is true' do
        before do
          ENV['LIMIT_INT_QUERIES'] = 'true'
        end

        after do
          ENV['LIMIT_INT_QUERIES'] = nil
        end

        context 'when user is not logged in' do
          before do
            visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
                  '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
          end

          it 'redirects to query limit page' do
            expect(page).to have_current_path('/query_limit_error')
          end

          context 'when the user is able to login' do
            before do
              user = User.create!(email: 'user1234@psu.edu')
              login_as(user, scope: :user)
              click_link 'Log In', href: login_path
            end

            it 'resumes the search' do
              expect(page).to have_current_path('/?f%5Baccess_facet%5D%5B%5D=In+the+Library&f%5B' \
                                                'campus_facet%5D%5B%5D=University+Park&f%5Bformat%5D%5B%5D' \
                                                '=Book&f%5Bup_library_facet%5D%5B%5D=Pattee+Library+and+' \
                                                'Paterno+Library+Stacks')
              expect(page).to have_css 'article[data-document-id="24053587"]'
            end
          end
        end
      end
    end

    context 'when on the external solr instance' do
      before do
        page.driver.header 'X-Forwarded-For', '203.0.113.1'
      end

      context 'when LIMIT_EXT_QUERIES is false' do
        context 'when LIMIT_INT_QUERIES is false' do
          before do
            ENV['LIMIT_EXT_QUERIES'] = 'false'
            ENV['LIMIT_INT_QUERIES'] = 'false'
          end

          after do
            ENV['LIMIT_EXT_QUERIES'] = nil
            ENV['LIMIT_INT_QUERIES'] = nil
          end

          it 'does not require auth for multiple queries' do
            visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
                  '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
            expect(page).to have_current_path('/?f%5Baccess_facet%5D%5B%5D=In+the+Library&f%5B' \
                                              'campus_facet%5D%5B%5D=University+Park&f%5Bformat%5D%5B%5D' \
                                              '=Book&f%5Bup_library_facet%5D%5B%5D=Pattee+Library+and+' \
                                              'Paterno+Library+Stacks')
          end
        end

        context 'when LIMIT_INT_QUERIES is true' do
          before do
            ENV['LIMIT_INT_QUERIES'] = 'true'
            ENV['LIMIT_EXT_QUERIES'] = 'false'
          end

          after do
            ENV['LIMIT_INT_QUERIES'] = nil
            ENV['LIMIT_EXT_QUERIES'] = nil
          end

          it 'does not require auth for multiple queries' do
            visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
                  '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
            expect(page).to have_current_path('/?f%5Baccess_facet%5D%5B%5D=In+the+Library&f%5B' \
                                              'campus_facet%5D%5B%5D=University+Park&f%5Bformat%5D%5B%5D' \
                                              '=Book&f%5Bup_library_facet%5D%5B%5D=Pattee+Library+and+' \
                                              'Paterno+Library+Stacks')
          end
        end
      end

      context 'when LIMIT_EXT_QUERIES is true' do
        before do
          ENV['LIMIT_EXT_QUERIES'] = 'true'
        end

        after do
          ENV['LIMIT_EXT_QUERIES'] = nil
        end

        context 'when user is not logged in' do
          before do
            visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
                  '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
          end

          it 'redirects to query limit page' do
            expect(page).to have_current_path('/query_limit_error')
          end

          context 'when the user is able to login' do
            before do
              user = User.create!(email: 'user1234@psu.edu')
              login_as(user, scope: :user)
              click_link 'Log In', href: login_path
            end

            it 'resumes the search' do
              expect(page).to have_current_path('/?f%5Baccess_facet%5D%5B%5D=In+the+Library&f%5B' \
                                                'campus_facet%5D%5B%5D=University+Park&f%5Bformat%5D%5B%5D' \
                                                '=Book&f%5Bup_library_facet%5D%5B%5D=Pattee+Library+and+' \
                                                'Paterno+Library+Stacks')
              expect(page).to have_css 'article[data-document-id="24053587"]'
            end
          end
        end
      end
    end

    context 'when user is logged in' do
      before do
        user = User.create!(email: 'user1234@psu.edu')
        login_as(user, scope: :user)
      end

      it 'displays search results' do
        visit '/?f[access_facet][]=In+the+Library&f[campus_facet][]=University+Park&f[format][]=Book' \
              '&f[up_library_facet][]=Pattee+Library+and+Paterno+Library+Stacks'
        expect(page).to have_css 'article[data-document-id="24053587"]'
      end
    end
  end

  context 'when Browse Limit is enabled' do
    before do
      ENV['BROWSE_LIMIT_ENABLED'] = 'true'
    end

    after do
      ENV['BROWSE_LIMIT_ENABLED'] = nil
    end

    it 'redirects to query limit page when browsing' do
      visit '/browse/authors?prefix=matt+dinniman'
      expect(page).to have_current_path('/query_limit_error')
    end
  end

  context 'when Browse Limit is disabled' do
    before do
      ENV['BROWSE_LIMIT_ENABLED'] = 'false'
    end

    after do
      ENV['BROWSE_LIMIT_ENABLED'] = nil
    end

    it 'does not redirect to query limit page when browsing' do
      visit '/browse/authors?prefix=matt+dinniman'
      expect(page).to have_current_path('/browse/authors?prefix=matt+dinniman')
    end
  end
end
