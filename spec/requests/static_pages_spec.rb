require 'spec_helper'

describe "Static Pages" do

  describe "Home Page" do
    before do
      visit '/static_pages/home'
    end
    it "should have content 'Wamibrew'" do
      expect(page).to have_content('Wamibrew')
    end
  end

  describe "Help Page" do
    before do
      visit '/static_pages/help'
    end
    it "should have content 'Help'" do
      expect(page).to have_content('Help')
    end
  end

  describe "About Page" do
    before do
      visit '/static_pages/about'
    end
    it "should have content 'About'" do
      expect(page).to have_content('About')
    end
  end
end
