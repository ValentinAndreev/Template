require 'rails_helper'

feature "User's actions on reviews" do
  let!(:user) { create(:user) }
  let!(:another_user) { create(:user, username: 'another_name', email: 'another@mail.com') }  
  let!(:movie) { create(:movie) }
  let!(:review) { create(:review, user_id: user.id, movie_id: movie.id, text: 'Text of review') }  
  let!(:another_review) { create(:review, user_id: another_user.id, movie_id: movie.id, text: 'Another review') }
  before do
    log_in_user(user.username, user.password)
    click_on 'All movies'
    click_on "#{movie.title} (#{movie.release_date.year})"
  end

  scenario 'user can open own review' do
    click_on 'My review'
    expect(page).to have_content("Text of review")
  end

  scenario 'user can edit own review' do
    click_on 'My review'    
    click_on 'Edit review'
    fill_in "review[text]", with: 'Edited review'    
    click_on 'Submit'
    expect(page).to_not have_content("Text of review")
    expect(page).to have_content("Edited review")
  end  

  scenario 'user can delete and create own review' do   
    click_on 'My review'
    click_on 'Destroy'
    expect(page).to_not have_content("Edited review")
    click_on 'To movie'
    click_on 'Create review'
    fill_in "review[text]", with: 'Text of review'
    click_on 'Submit'
    check_list_of_content(['My review for', 'Text of review'])
  end

  scenario 'user can see all reviews' do
    click_on 'All reviews'
    check_list_of_content(["Text of review", 'Another review'])
  end

  scenario 'user can only see another users reviews' do
    click_on 'All reviews'
    click_on 'Destroy'    
    check_list_of_content(['Edit review', 'Destroy'], false)
    click_on 'Show'
    expect(page).to have_content("Review of #{another_user.username} for #{movie.title} (#{movie.release_date.year})")
  end  
end