require 'rails_helper'
require 'support/features/clearance_helpers'

RSpec.feature 'Post', type: :feature do
  before(:each) do
    sign_in
  end

  scenario 'Posts have a timestamps' do
    visit '/posts'
    click_link 'New post'
    fill_in 'Message', with: 'Hello, world!'
    click_button 'Submit'
    expect(page).to have_content('Hello, world!')
    expect(page).to have_content('UTC')
  end

  scenario 'Posts with mutliple lines are displayed in multiple lines' do
    visit '/posts'
    click_link 'New post'
    fill_in 'Message', with: 'Hello, world!\nThis is a new line\nAnd another line.'
    click_button 'Submit'
    expect(page).to have_selector('p', text: 'Hello, world!')
    expect(page).to have_selector('p', text: 'This is a new line')
    expect(page).to have_selector('p', text: 'And another line.')
    expect(page).not_to have_selector('p', text: "Hello, world!\nThis is a new line\nAnd another line.")
  end

  context 'user creates a post' do
    scenario "post on another user's wall" do
      user_b = FactoryBot.create(:user)
      user_b.create_wall!
      user_a_wall = page.current_path

      visit "/users/#{user_b.id}/wall"
      click_link 'New post'
      fill_in 'Message', with: "Hello, user b's wall! - User a"
      click_button 'Submit'

      visit "/users/#{user_b.id}/wall"
      expect(page).to have_content "Hello, user b's wall! - User a"

      visit user_a_wall
      expect(page).not_to have_content "Hello, user b's wall! - User a"
    end
  end

  context 'user deletes a post' do
    scenario 'Posts can be deleted' do
      visit '/posts'
      click_link 'New post'
      fill_in 'Message', with: 'Delete me!'
      click_button 'Submit'
      expect(page).to have_content('Delete me!')
      click_link 'Delete'
      expect(page).not_to have_content('Delete me!')
    end

    scenario "Post's cannot be deleted by other users" do
      visit '/posts'
      click_link 'New post'
      fill_in 'Message', with: 'message before edit'
      click_button 'Submit'
      click_button 'Sign out'
      sign_up_with('anotherEmail@Email.com', 'password')
      click_link 'Delete'
      expect(page).to have_content("You don't own this post. Cannot be deleted.")
    end
  end

  context 'User logs in' do
    scenario 'User sees a successful login message on login' do
      expect(page).to have_content 'You have successfully logged in.'
    end

    scenario 'Successful login message is not present on the next page' do
      click_link 'New post'
      expect(page).not_to have_content 'You have successfully logged in.'
    end
  end

  context 'user edits a post' do
    scenario 'User can edit his post' do
      visit '/posts'
      click_link 'New post'
      fill_in 'Message', with: 'message before edit'
      click_button 'Submit'
      expect(page).to have_content('message before edit')
      click_link 'Edit'
      fill_in 'Message', with: 'message after edit'
      click_button 'Submit'
      expect(page).to have_content('message after edit')
      expect(page).not_to have_content('message before edit')
    end

    scenario 'Post can only be edited up to 10min after they have been created' do
      visit '/posts'
      click_link 'New post'
      fill_in 'Message', with: "Hello, world!\nThis is a new line\nAnd another line."
      click_button 'Submit'
      current_time_plus11 = Time.now + 660
      allow(Time).to receive(:now).and_return(current_time_plus11)
      page.reset!
      expect(page).not_to have_link 'Edit'
    end

    scenario 'Post\'s cannot be edited by other users' do
      visit '/posts'
      click_link 'New post'
      fill_in 'Message', with: 'message before edit'
      click_button 'Submit'
      click_button 'Sign out'
      sign_up_with('anotherEmail@Email.com', 'password')
      click_link 'Edit'
      fill_in 'Message', with: 'message after edit'
      click_button 'Submit'
      expect(page).to have_content("You can't edit another user's post!")
    end
  end
end
