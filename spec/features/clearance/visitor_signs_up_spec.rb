require 'rails_helper'
require 'support/features/clearance_helpers'

RSpec.feature 'Visitor signs up' do
  scenario 'by navigating to the page' do
    visit sign_in_path
    click_link I18n.t('sessions.form.sign_up')
    expect(current_path).to eq sign_up_path
  end

  scenario 'with valid email and password' do
    sign_up_with 'example_username', 'valid@example.com', 'password'
    expect_user_to_be_signed_in
  end
end

RSpec.feature 'Validating sign up' do
  scenario 'tries with invalid email' do
    sign_up_with 'invalid_username', 'invalid_email', 'password'
    expect_user_to_be_signed_out
  end

  scenario 'tries with email that already exists' do
    sign_up_with 'Test', 'valid@example.com', 'password'
    click_button 'Sign out'
    click_link 'Sign up'
    sign_up_with 'Test2', 'valid@example.com', 'password'
    expect(page).to have_content('Email already exists')
    expect_user_to_be_signed_out
  end

  scenario 'tries with blank password' do
    sign_up_with  'example_username', 'valid@example.com', ''
    expect_user_to_be_signed_out
  end

  scenario 'tries with invalid password 1' do
    sign_up_with 'example_username', 'valid@example.com', '12'
    expect(current_path).to eq(sign_up_path)
    expect(page).to have_content('Password must be between 6 - 10 characters')
  end

  scenario 'tries with invalid password 2' do
    sign_up_with 'example_username', 'valid@example.com', '12345678910'
    expect(current_path).to eq(sign_up_path)
    expect(page).to have_content('Password must be between 6 - 10 characters')
  end

  scenario 'tries with an blank username' do
    sign_up_with '', 'valid@example.com', 'password'
    expect(page).to have_content('Username must be at least 3 characters')
    expect_user_to_be_signed_out
  end

  scenario 'tries with username that already exists' do
    sign_up_with 'asdfghjkl', 'valid@example.com', 'password'
    click_button 'Sign out'
    click_link 'Sign up'
    sign_up_with 'asdfghjkl', 'valid2@example.com', 'password'
    expect(page).to have_content('Username taken')
    expect_user_to_be_signed_out
  end

  scenario 'sees a confirmation flash message that he has signed up' do
    sign_up_with 'example_username', 'valid@example.com', 'password'
    expect(page).to have_content 'You are now registered to Acebook! Welcome!'
    click_link 'New post'
    expect(page).not_to have_content 'You are now registered to Acebook! Welcome!'
  end
end
