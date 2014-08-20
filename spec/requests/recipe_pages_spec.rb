require 'spec_helper'

describe "Recipe Pages" do

  describe "new recipe page" do
    before { visit new_recipe_path }

    it "should have correct title and header" do
      expect(page).to have_title("Try Brewing...")
      expect(page).to have_content("Try Brewing...")
    end

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
    end

    describe "ingredients" do
      before do
        @recipe = Recipe.new
      end

      describe "malt" do

        describe "choose_malt" do
          before do
            @malt = @recipe.choose_malt
          end
          it "should choose a malt" do
            expect(@malt).not_to be_nil
          end
        end
      end

      describe "hops" do
        describe "choose_hops" do
          before do
            @hop = @recipe.choose_hops
          end
          it "should choose a hop" do
            expect(@hop).not_to be_nil
          end
        end
      end

      describe "yeast" do
        describe "choose_yeast" do
          before do
            @yeast = @recipe.choose_yeast
          end
          it "should choose a yeast" do
            expect(@yeast).not_to be_nil
          end
        end
      end

    end

  end

end