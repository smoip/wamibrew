require 'spec_helper'

describe "Recipe Pages" do

  describe "new recipe page" do
    before { visit new_recipe_path }

    subject { page }

    it { shoud have_title("Try Brewing...") }
    it { should have_content("Try Brewing...") }

    describe "re-submit button" do

      it "should reload page" do
        expect do
          click_button "What Else Am I Brewing?"
          expect(response).to redirect_to(new_recipe_path)
        end
      end
    end

    describe "Recipe display format" do

      it "should have ingredient list elements" do
        expect(page).to have_selector('li', text: 'malt')
        expect(page).to have_selector('li', text: 'yeast')
        expect(page).to have_selector('li', text: 'hops')
      end

      it "should have specification list elements" do
        expect(page).to have_selector('li', text: 'abv')
        expect(page).to have_selector('li', text: 'ibu')
        expect(page).to have_selector('li', text: 'color')
      end

      it "should show malt names" do
        # needs testing!
      end

      it "should show hop names" do
        # needs testing!
      end

      it "should show yeast names" do
        # needs testing!
      end
    end

  end

end