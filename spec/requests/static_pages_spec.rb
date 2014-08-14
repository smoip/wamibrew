require 'spec_helper'

describe "Static Pages" do

  describe "Home Page" do
    before do
      visit '/static_pages/home'
    end
    it "should have content 'Wamibrew'" do
      expect(page).to have_content('Wamibrew')
    end
    # it { should have_title('Wamibrew') }
    it "should have the default title" do
      expect(page).not_to have_title('| Home')
      expect(page).to have_title('Wamibrew')
    end
  end

  describe "Help Page" do
    before do
      visit '/static_pages/help'
    end
    it "should have content 'Help'" do
      expect(page).to have_content('Help')
    end
    # it { should have_title('| Help')}
    it "should have title '| Help'" do
      expect(page).to have_title('| Help')
    end
  end

  describe "About Page" do
    before do
      visit '/static_pages/about'
    end
    it "should have content 'About'" do
      expect(page).to have_content('About')
    end
    # it { should have_title('| About') }
    it "should have title '| About'" do
      expect(page).to have_title('| About')
    end
  end
end
