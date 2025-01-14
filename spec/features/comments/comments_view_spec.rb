require 'rails_helper'
require 'support/features/clearance_helpers'

RSpec.feature 'Comment', type: :feature do
  before(:each) do
    sign_in
  end

  scenario 'Can access comments' do
    visit '/posts'
    click_link 'New post'
    fill_in 'Message', with: 'Hello, world!'
    click_button 'Submit'
    expect(page).to have_content('Hello, world!')
    click_link 'View Post'
    expect(page).to have_content('Add a comment')
    fill_in 'comment[body]', with: 'Comment number 1'
    click_button 'Submit'
    expect(page).to have_content('Comment number 1')
  end
end
