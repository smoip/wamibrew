require 'spec_helper'

describe "Static Pages" do

  describe "Home Page" do
    before { visit '/static_pages/home' }
    subject { page }

    it { should have_content('Wamibrew') }
    it "should have content 'Wamibrew'" do
      expect(page).to have_content('Wamibrew')
    end
    it { should_not have_title('Home') }
    it { should have_title('Wamibrew') }

    it "should have footer links" do
      expect(page).to have_link('About', href: about_path)
      expect(page).to have_link('Help', href: help_path)
      expect(page).to have_link('Contact', href: contact_path)
    end

    describe "wami button" do
      it "should link to the recipe page" do
        expect do
          click_button "What Am I Brewing?"
          expect(response).to redirect_to(new_recipe_path)
        end
      end
    end
  end

  describe "Help Page" do
    before { visit '/static_pages/help' }
    subject { page }

    it { should have_content('Help') }
    it { should have_title('| Help')}
  end

  describe "About Page" do
    before { visit '/static_pages/about' }
    subject { page }

    it { should have_content('About') }
    it { should have_title('| About') }
  end

  describe "Contact Page" do
    before { visit '/static_pages/contact' }
    subject { page }

    it { should have_content('Contact') }
    it { should have_title('| Contact') }
  end
end
