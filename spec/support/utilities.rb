include ApplicationHelper

# Abstract over how to detect an error on a page
Rspec::Matchers.define :have_error do
  match do |page|
    expect(page).to have_content('error')
  end
end

# Abstract over having a particular error message on a page
Rspec::Matchers.define :have_error_message do |msg|
  match do |page|
    if msg && !msg.empty?
      expect(page).to have_selector('div.alert.alert-error', text: msg)
    else
      expect(page).to have_selector('div.alert.alert-error')
    end
  end
end

# Abstract over what exactly is a profile page - at the moment it's a page with the user's name as title
Rspec::Matchers.define :be_profile_page do |user|
  match do |page|
    expect(page).to have_title(user.name)
  end
end
