require 'rails_helper'

  describe "name" do
    before do
      @recipe = Recipe.new
      @recipe.save!
    end
    after { @recipe.destroy! }
    let(:hop) { FactoryGirl.build(:hop) }
    let(:malt) { FactoryGirl.build(:malt) }
    let(:style) { FactoryGirl.build(:style) }
    let(:yeast) { FactoryGirl.build(:yeast) }

    describe "generate_name" do
      before do
        allow( @recipe ).to receive( :check_smash ).and_return(nil)
        allow( @recipe ).to receive( :add_yeast_family ).and_return(nil)
        allow( @recipe ).to receive( :add_ingredient_to_name ).and_return(nil)
        allow( @recipe ).to receive( :add_color_to_name ).and_return(nil)
        allow( @recipe ).to receive( :add_strength_to_name ).and_return(nil)
        allow( @recipe ).to receive( :add_article ).and_return(nil)
      end
      after { @recipe.name = nil }

      context "with no style assigned" do
        before do
          @recipe.name = 'Beer'
          @recipe.style = nil
        end

        it "should assign the default name" do
          @recipe.generate_name
          expect( @recipe.name ).to eq( "Beer" )
        end
      end

      context "with assigned style" do
        before { @recipe.style = style }
        after { @recipe.style = nil }
        it "should assign the style name" do
          @recipe.generate_name
          expect( @recipe.name ).to eq( 'American IPA' )
        end
      end
    end

    describe "check_smash" do
      context "with assigned style present" do
        before do
          @recipe.name = 'IPA'
          @recipe.style = 'IPA'
        end
        it "should not change name" do
          expect { @recipe.check_smash }.not_to raise_error
          expect( @recipe.name ).to eq( 'IPA' )
        end
      end

      context "without assigned style" do
        before { @recipe.style = nil }
        it "should attempt to generate smash name" do
          expect { @recipe.check_smash }.to raise_error( NoMethodError )
        end
      end
    end

    describe "single_hop?" do
      context "single type of hop in hop instance variable" do
        let(:single_hop) { { :bittering => {  hop => [ 1.5, 60 ] }, :aroma=> [] } }
        before { @recipe.hops = single_hop }
        it "should be true" do
          expect( @recipe.single_hop? ).to be( true )
        end
      end

      context "multiple types of hops in hop instance variable" do
        let(:hop_2) { FactoryGirl.build(:hop, name: 'centennial test') }
        let(:multi_hop) { { :bittering => {  hop => [ 1.5, 60 ] }, :aroma=> [ { hop_2 => [1, 5] } ] } }
        before { @recipe.hops = multi_hop }
        it "should be false" do
          expect( @recipe.single_hop? ).to be( false )
        end
      end

    end

    describe "single_malt?" do
      context "single type of malt in malt instance variable" do
        let(:single_malt)  { { :base => { malt => 9 }, :specialty => {} } }
        before { @recipe.malts = single_malt }
        it "should be true" do
          expect( @recipe.single_malt? ).to be( true )
        end
      end

      context "multiple types of malts in malt instance variable" do
        let(:malt_2) { FactoryGirl.build(:malt, name: 'black malt test') }
        let(:multi_malt) { { :base => { malt => 9 }, :specialty => { malt_2 => 1 } } }
        before { @recipe.malts = multi_malt }
        it "should be false" do
          expect( @recipe.single_malt? ).to be( false )
        end
      end
    end

    describe "capitalize_titles" do
      it "should capitalize multi-word titles" do
        expect( @recipe.capitalize_titles( 'delicious red wheat' ) ).to eq( 'Delicious Red Wheat' )
      end

      it "should capitalize one-word titles" do
        expect( @recipe.capitalize_titles( 'wheat' ) ).to eq( 'Wheat' )
      end
    end

    describe "add_ingredient_to_name" do
      it "needs to test for ingredient additions"
      #requires overhaul of this method
    end

    describe "add_yeast_family" do
      before do
        @recipe.name = 'Beer'
      end
      after do
        @recipe.name = nil
        @recipe.style = nil
      end

      context "with assigned style" do
        before { @recipe.style = style }
        it "should not alter the name" do
          @recipe.add_yeast_family
          expect( @recipe.name ).to eq( 'Beer' )
        end
      end

      context "without assigned style" do
        before do
          @recipe.style = nil
          @recipe.yeast = yeast
          allow( @recipe ).to receive( :one_of_four ).and_return( 1 )
          allow( @recipe ).to receive( :capitalize_titles ).and_return( 'Ale' )
        end
        after { @recipe.yeast = nil }

        it "should alter the name" do
          @recipe.add_yeast_family
          expect( @recipe.name ).to eq( 'Ale' )
        end
      end
    end
    describe "color" do

      describe "add_color_to_name" do
        it "needs to test"
        #scheduled for 7/23
      end

      describe "check_smash_name" do
        it "needs to test"
        #scheduled for 7/23
      end

      describe "color_lookup" do
        it "needs to test"
        #scheduled for 7/23
      end

      describe "choose_color_adjective" do
        it "needs to test"
        #scheduled for 7/23
      end
    end

    describe "strength" do
      describe "add_strength_to_name" do
        it "needs to test"
        #scheduled for 7/23
      end

      describe "strength_lookup" do
        it "needs to test"
        #scheduled for 7/23
      end

      describe "choose_strength_adjective" do
        it "needs to test"
        #scheduled for 7/23
      end
    end

    describe "add_adjective" do
      context "with no style" do
        before { @recipe.style = nil }

        it "should prepend an adjective to the name" do
          @recipe.add_adjective( 'Beer', 'Viscous' )
          expect(@recipe.name).to eq( 'Viscous Beer' )
        end
      end
      context "with assigned style" do
        before { @recipe.style = style }
        it "should insert an adjective between words in the name" do
          @recipe.add_adjective( 'American IPA', 'Viscous' )
          expect(@recipe.name).to eq( 'American Viscous IPA' )
        end
      end
    end

    describe "add_article" do
      context "with name \'ale\'" do
        before { @recipe.name = 'Ale' }
        it "should add \'An\'" do
          @recipe.add_article
          expect(@recipe.name).to eq( 'An Ale' )
        end
      end

      context "with other vowel-start name" do
        before { @recipe.name  = "Imperial Stout" }
        it "should add \'An\'" do
          @recipe.add_article
          expect(@recipe.name).to eq( "An Imperial Stout" )
        end
      end

      context "with consonant-start" do
        before { @recipe.name = "Session IPA" }
        it "should add \'A\'" do
          @recipe.add_article
          expect(@recipe.name).to eq( "A Session IPA" )
        end
      end
    end

  end

