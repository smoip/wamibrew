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

        context "with assigned style" do
          before { @recipe.style = style }
          it "should not attempt to pick an adjective" do
            expect { @recipe.add_color_to_name }.not_to raise_error
          end
        end

        context "without assigned style" do
          before do
            @recipe.style = nil
            allow( @recipe ).to receive( :one_of_four ).and_return( 1 )
          end
          it "should attempt to pick an adjective" do
            expect { @recipe.add_color_to_name }.to raise_error
          end
        end
      end

      describe "check_smash_name" do
        context "includes \'SMASH\'" do
          before { @recipe.name = 'Golden Promise Saaz SMASH' }
          after { @recipe.name = nil }
          it "should be true" do
            expect( @recipe.check_smash_name ).to be( true )
          end
        end
        context "does not include \'SMASH\'" do
          before { @recipe.name = 'Red Ale' }
          after { @recipe.name = nil }
          it "should be false" do
            expect( @recipe.check_smash_name ).to be( false )
          end
        end
      end

      describe "color_lookup" do
        after { @recipe.srm = nil }
        context "srm < 3" do
          before { @recipe.srm = 1.2 }
          it "should be \'yellow\'" do
            expect( @recipe.color_lookup ).to eq( :yellow )
          end
        end

        context "srm = 3" do
          before { @recipe.srm = 3.0 }
          it "should be \'yellow\'" do
            expect( @recipe.color_lookup ).to eq( :yellow )
          end
        end

        context "srm 4-7" do
          before { @recipe.srm = 5.4 }
          it "should be \'gold\'" do
            expect( @recipe.color_lookup ).to eq( :gold )
          end
        end

        context "srm 8-11" do
          before { @recipe.srm = 9.8 }
          it "should be \'amber\'" do
            expect( @recipe.color_lookup ).to eq( :amber )
          end
        end

        context "srm 12-14" do
          before { @recipe.srm = 12.1 }
          it "should be \'red\'" do
            expect( @recipe.color_lookup ).to eq( :red )
          end
        end

        context "srm 15-20" do
          before { @recipe.srm = 18.6 }
          it "should be \'brown\'" do
            expect( @recipe.color_lookup ).to eq( :brown )
          end
        end

        context "srm 21-25" do
          before { @recipe.srm = 23.0 }
          it "should be \'dark_brown\'" do
            expect( @recipe.color_lookup ).to eq( :dark_brown )
          end
        end

        context "srm 26-35" do
          before { @recipe.srm = 34.2 }
          it "should be \'black\'" do
            expect( @recipe.color_lookup ).to eq( :black )
          end
        end

        context "srm 36+" do
          before { @recipe.srm = 48.3 }
          it "should be \'dark_black\'" do
            expect( @recipe.color_lookup ).to eq( :dark_black )
          end
        end
      end

      describe "choose_color_adjective" do
        let(:options) { [] }

        context "color yellow" do
          before  { [ "Straw", "Blonde", "Light Gold" ].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a yellow synonym" do
            expect( [ [ @recipe.choose_color_adjective( :yellow ) ] & options ][0] ).to be_truthy
          end
        end

        context "color gold" do
          before  { [ "Gold", "Golden", "Blonde" ].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a gold synonym" do
            expect( [ [ @recipe.choose_color_adjective( :gold ) ] & options ][0] ).to be_truthy
          end
        end

        context "color amber" do
          before  { [ "Amber", "Copper" ].each { |adj| options << adj } }
          after { options = [] }
          it "should choose an amber synonym" do
            expect( [ [ @recipe.choose_color_adjective( :amber ) ] & options ][0] ).to be_truthy
          end
        end

        context "color red" do
          before  { [ "Amber", "Red" ].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a red synonym" do
            expect( [ [ @recipe.choose_color_adjective( :red ) ] & options ][0] ).to be_truthy
          end
        end

        context "color brown" do
          before  { [ "Chestnut", "Brown"].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a brown synonym" do
            expect( [ @recipe.choose_color_adjective( :brown ) ] & options ).to be_truthy
          end
        end

        context "color dark brown" do
          before  { [ "Dark Brown", "Brown"].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a dark brown synonym" do
            expect( [ [ @recipe.choose_color_adjective( :dark_brown ) ] & options ][0] ).to be_truthy
          end
        end

        context "color black" do
          before  { [ "Black", "Dark Brown"].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a black synonym" do
            expect( [ [ @recipe.choose_color_adjective( :black ) ] & options ][0] ).to be_truthy
          end
        end

        context "color dark black" do
          before  { [ "Black", "Jet Black"].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a dark black synonym" do
            expect( [ [ @recipe.choose_color_adjective( :dark_black ) ] & options ][0] ).to be_truthy
          end
        end

      end
    end

    describe "strength" do
      describe "add_strength_to_name" do

        context "with assigned style" do
          before { @recipe.style = style }
          it "should not attempt to pick an adjective" do
            expect { @recipe.add_strength_to_name }.not_to raise_error
          end
        end

        context "without assigned style" do
          before do
            @recipe.style = nil
            allow( @recipe ).to receive( :one_of_four ).and_return( 1 )
          end
          it "should attempt to pick an adjective" do
            expect { @recipe.add_strength_to_name }.to raise_error
          end
        end
      end

      describe "strength_lookup" do
        after { @recipe.abv = nil }
        context "abv 0-2" do
          before { @recipe.abv = 1.8 }
          it "should be \'weak\'" do
            expect( @recipe.strength_lookup ).to eq( :weak )
          end
        end

        context "abv 3-4" do
          before { @recipe.abv = 3.0 }
          it "should be \'session\'" do
            expect( @recipe.strength_lookup ).to eq( :session )
          end
        end

        context "abv 5-7" do
          before { @recipe.abv = 7.0 }
          it "should be \'average\'" do
            expect( @recipe.strength_lookup ).to eq( :average )
          end
        end

        context "abv 8-9" do
          before { @recipe.abv = 8.9 }
          it "should be \'strong\'" do
            expect( @recipe.strength_lookup ).to eq( :strong )
          end
        end

        context "abv 10+" do
          before { @recipe.abv = 15 }
          it "should be \'very_strong\'" do
            expect( @recipe.strength_lookup ).to eq( :very_strong )
          end
        end

      end

      describe "choose_strength_adjective" do
        let(:options) { [] }
        context "strength weak" do
          before  { [ "Mild", "Low Gravity" ].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a weak synonym" do
            expect( [ [ @recipe.choose_strength_adjective( :weak ) ] & options ][0] ).to be_truthy
          end
        end

        context "strength session" do
          before  { [ "sessionable", "quaffable" ].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a weak synonym" do
            expect( [ [ @recipe.choose_strength_adjective( :session ) ] & options ][0] ).to be_truthy
          end
        end

        context "strength average" do
          it "should not choose an adjective" do
            expect( @recipe.choose_strength_adjective( :average ) ).to eq( '' )
          end
        end

        context "strength strong" do
          before  { [ "Strong" ].each { |adj| options << adj } }
          after { options = [] }
          it "should choose a strong synonym" do
            expect( [ [ @recipe.choose_strength_adjective( :strong ) ] & options ][0] ).to be_truthy
          end
        end
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