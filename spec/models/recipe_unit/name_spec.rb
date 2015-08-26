# require 'spec_helper'

  describe "name" do
    before do
      @recipe = Recipe.new
      @recipe.save!
    end
    after { @recipe.destroy! }
    let(:hop)    { FactoryGirl.build(:hop) }
    let(:malt)   { FactoryGirl.build(:malt) }
    let(:malt_2) { FactoryGirl.build(:malt, name: 'black malt test') }
    let(:style)  { FactoryGirl.build(:style) }
    let(:yeast)  { FactoryGirl.build(:yeast) }
    let(:sugar) { Malt.find_by_name( 'honey' ) }

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
          expect( @recipe.name ).to eq( 'IPA' )
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
          allow( @recipe ).to receive( :single_malt? ).and_return( true )
          allow( @recipe ).to receive( :single_hop? ).and_return( true )
          expect { @recipe.check_smash }.to raise_error
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
      let(:malt_3) { Malt.find_by_name( 'rye malt' ) }
      let(:malt_4) { Malt.find_by_name( 'white wheat' ) }
      before { @recipe.malts = { :base => { malt => 10 }, :specialty => {} } }
      # above three lines can be removed once 'multiple adjective-able malts' is moved to integration
      context "recipe includes one adjective-able malt" do
        before do
          allow( @recipe ).to receive( :get_required_malts ).and_return( [] )
          @recipe.name = 'Beer'
        end
        it "adds \'rye\' to the name" do
          allow( @recipe ).to receive( :choose_ingredient_adjective ).and_return( 'rye' )
          @recipe.add_ingredient_to_name
          expect( @recipe.name ).to eq( 'Rye Beer' )
        end
        it "adds \'honey\' to the name" do
          allow( @recipe ).to receive( :choose_ingredient_adjective ).and_return( 'honey' )
          @recipe.add_ingredient_to_name
          expect( @recipe.name ).to eq( 'Honey Beer' )
        end
      end
      context "recipe includes multiple adjective-able malts" do
        # move this context to integration tests
        before do
          @recipe.name = 'Beer'
          @recipe.malts[:specialty] = { malt_3 => 2.5, malt_4 => 2 }
        end
        it "adds an adjective to the name" do
          adjectives = [ "Rye", "Wheat" ]
          @recipe.add_ingredient_to_name
          expect( ( @recipe.name.split(' ') & adjectives )[0] ).to be_truthy
        end
        it "does not add multiple adjectives to the name" do
          @recipe.name = 'Beer'
          @recipe.add_ingredient_to_name
          expect( @recipe.name ).not_to eq( 'Rye Wheat Beer' )
          expect( @recipe.name ).not_to eq( 'Wheat Rye Beer' )
        end
      end
      context "recipe includes no adjective-able malts" do
        before { @recipe.name = 'Beer' }
        it "does not add an adjective to the name" do
          allow( @recipe ).to receive( :choose_ingredient_adjective ).and_return( nil )
          allow( @recipe ).to receive( :get_required_malts ).and_return( [ 'wheat' ] )
          @recipe.add_ingredient_to_name
          expect( @recipe.name ).to eq( 'Beer' )
        end
      end
      context "recipe includes an adjective-able malt which is also a required malt for style" do
        before { @recipe.name = 'Beer' }
        it "does not add an adjective to the name" do
          allow( @recipe ).to receive( :choose_ingredient_adjective ).and_return( 'wheat' )
          allow( @recipe ).to receive( :get_required_malts ).and_return( [ 'wheat' ] )
          @recipe.add_ingredient_to_name
          expect( @recipe.name ).to eq( 'Beer' )
        end
      end
      context "recipe includes oats" do
        before { @recipe.name = 'Beer' }
        it "adds \'oatmeal\' rather than \'oats\'" do
          allow( @recipe ).to receive( :choose_ingredient_adjective ).and_return( 'oats' )
          allow( @recipe ).to receive( :get_required_malts ).and_return( [] )
          @recipe.add_ingredient_to_name
          expect( @recipe.name ).to eq( 'Oatmeal Beer' )
        end
      end
    end

    describe "choose_ingredient_adjective" do
      let(:malt_3) { Malt.find_by_name( 'rye malt' ) }
      let(:malt_4) { Malt.find_by_name( 'white wheat' ) }
      before { @recipe.malts = { :base => { malt => 10 }, :specialty => {} } }
      context "recipe includes one adjective-able malt" do
        it "returns \'rye\'" do
          @recipe.malts[:specialty] = { malt_3 => 2 }
          expect( @recipe.choose_ingredient_adjective ).to eq( 'rye' )
        end
        it "returns \'honey\'" do
          @recipe.malts[:specialty] = { sugar => 2 }
          expect( @recipe.choose_ingredient_adjective ).to eq( 'honey' )
        end
      end
      context "recipe includes multiple adjective-able malts" do
        it "returns only one adjective" do
          @recipe.malts[:specialty] = { malt_3 => 2 }
          adjs = [ 'honey', 'rye' ]
          expect( ( [ @recipe.choose_ingredient_adjective ] & adjs )[0] ).not_to eq( nil )
          expect( ( [ @recipe.choose_ingredient_adjective ] & adjs )[0] ).to be_truthy
        end
      end
      context "recipe includes no adjective-able malts" do
        it "returns nothing" do
          @recipe.malts[:specialty] = {}
          expect( @recipe.choose_ingredient_adjective ).to eq( nil )
        end
      end
    end

    describe "get_required_malts" do
      context "assigned style has no required malts" do
        before { @recipe.style = nil }
        it "returns an empty array" do
          expect( @recipe.get_required_malts ).to eq( [] )
        end
      end
      context "assigned style has one required malt" do
        let(:style_2) { FactoryGirl.build(:style, required_malts: [ '2-row' ] ) }
        before { @recipe.style = style_2 }
        it "returns an array containing the test malt name" do
          expect( @recipe.get_required_malts ).to eq( [ '2-row' ] )
        end
      end
      context "assigned style has multiple required malts" do
        let(:style_3) { FactoryGirl.build(:style, required_malts: [ '2-row', 'black malt' ] ) }
        before { @recipe.style = style_3 }
        it "returns an array containing two test malt names" do
          expect( @recipe.get_required_malts ).to eq( [ '2-row', 'black', 'malt' ] )
        end
      end
    end
    describe "oatmeal_check" do
      it "should change oats to oatmeal" do
        expect( @recipe.oatmeal_check('oats') ).to eq( 'oatmeal' )
      end
      it "does not change non-oat words" do
        expect( @recipe.oatmeal_check('rye') ).to eq( 'rye' )
      end
    end

    # describe "add_yeast_family" do
    #   before do
    #     @recipe.name = 'Beer'
    #   end
    #   after do
    #     @recipe.name = nil
    #     @recipe.style = nil
    #   end

    #   context "with assigned style" do
    #     before { @recipe.style = style }
    #     it "should not alter the name" do
    #       @recipe.add_yeast_family
    #       expect( @recipe.name ).to eq( 'Beer' )
    #     end
    #   end

    #   context "without assigned style" do
    #     before do
    #       @recipe.style = nil
    #       @recipe.yeast = yeast
    #       allow( @recipe ).to receive( :rand ).and_return( 1 )
    #     end
    #     after { @recipe.yeast = nil }

    #     it "should alter the name" do
    #       allow( @recipe ).to receive( :capitalize_titles ).and_return( 'Ale' )
    #       @recipe.add_yeast_family
    #       expect( @recipe.name ).to eq( 'Ale' )
    #     end
    #     it "should not add the yeast family \'wheat\'" do
    #       allow( @recipe.yeast ).to receive( :family ).and_return( 'wheat' )
    #       @recipe.add_yeast_family
    #       expect( @recipe.name ).not_to eq( 'Wheat' )
    #     end
    #   end
    # end

    describe "color" do

      # describe "add_color_to_name" do

      #   context "with assigned style" do
      #     before { @recipe.style = style }
      #     it "should not attempt to pick an adjective" do
      #       expect { @recipe.add_color_to_name }.not_to raise_error
      #     end
      #   end

      #   context "without assigned style" do
      #     before do
      #       @recipe.style = nil
      #       allow( @recipe ).to receive( :rand ).and_return( 1 )
      #     end
      #     it "should attempt to pick an adjective" do
      #       expect { @recipe.add_color_to_name }.to raise_error
      #     end
      #   end
      # end

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

      # describe "color_lookup" do
      #   after { @recipe.srm = nil }
      #   context "srm < 3" do
      #     before { @recipe.srm = 1.2 }
      #     it "should be \'yellow\'" do
      #       expect( @recipe.color_lookup ).to eq( :yellow )
      #     end
      #   end

      #   context "srm = 3" do
      #     before { @recipe.srm = 3.0 }
      #     it "should be \'yellow\'" do
      #       expect( @recipe.color_lookup ).to eq( :yellow )
      #     end
      #   end

      #   context "srm 4-7" do
      #     before { @recipe.srm = 5.4 }
      #     it "should be \'gold\'" do
      #       expect( @recipe.color_lookup ).to eq( :gold )
      #     end
      #   end

      #   context "srm 8-11" do
      #     before { @recipe.srm = 9.8 }
      #     it "should be \'amber\'" do
      #       expect( @recipe.color_lookup ).to eq( :amber )
      #     end
      #   end

      #   context "srm 12-14" do
      #     before { @recipe.srm = 12.1 }
      #     it "should be \'red\'" do
      #       expect( @recipe.color_lookup ).to eq( :red )
      #     end
      #   end

      #   context "srm 15-20" do
      #     before { @recipe.srm = 18.6 }
      #     it "should be \'brown\'" do
      #       expect( @recipe.color_lookup ).to eq( :brown )
      #     end
      #   end

      #   context "srm 21-25" do
      #     before { @recipe.srm = 23.0 }
      #     it "should be \'dark_brown\'" do
      #       expect( @recipe.color_lookup ).to eq( :dark_brown )
      #     end
      #   end

      #   context "srm 26-35" do
      #     before { @recipe.srm = 34.2 }
      #     it "should be \'black\'" do
      #       expect( @recipe.color_lookup ).to eq( :black )
      #     end
      #   end

      #   context "srm 36+" do
      #     before { @recipe.srm = 48.3 }
      #     it "should be \'dark_black\'" do
      #       expect( @recipe.color_lookup ).to eq( :dark_black )
      #     end
      #   end
      # end

      # describe "choose_color_adjective" do
      #   let(:options) { [] }

      #   context "color yellow" do
      #     before  { [ "Straw", "Blonde", "Light Gold" ].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose a yellow synonym" do
      #       expect( [ [ @recipe.choose_color_adjective( :yellow ) ] & options ][0] ).to be_truthy
      #     end
      #   end

      #   context "color gold" do
      #     before  { [ "Gold", "Golden", "Blonde" ].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose a gold synonym" do
      #       expect( [ [ @recipe.choose_color_adjective( :gold ) ] & options ][0] ).to be_truthy
      #     end
      #   end

      #   context "color amber" do
      #     before  { [ "Amber", "Copper" ].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose an amber synonym" do
      #       expect( [ [ @recipe.choose_color_adjective( :amber ) ] & options ][0] ).to be_truthy
      #     end
      #   end

      #   context "color red" do
      #     before  { [ "Amber", "Red" ].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose a red synonym" do
      #       expect( [ [ @recipe.choose_color_adjective( :red ) ] & options ][0] ).to be_truthy
      #     end
      #   end

      #   context "color brown" do
      #     before  { [ "Chestnut", "Brown"].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose a brown synonym" do
      #       expect( [ @recipe.choose_color_adjective( :brown ) ] & options ).to be_truthy
      #     end
      #   end

      #   context "color dark brown" do
      #     before  { [ "Dark Brown", "Brown"].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose a dark brown synonym" do
      #       expect( [ [ @recipe.choose_color_adjective( :dark_brown ) ] & options ][0] ).to be_truthy
      #     end
      #   end

      #   context "color black" do
      #     before  { [ "Black", "Dark Brown"].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose a black synonym" do
      #       expect( [ [ @recipe.choose_color_adjective( :black ) ] & options ][0] ).to be_truthy
      #     end
      #   end

      #   context "color dark black" do
      #     before  { [ "Black", "Jet Black"].each { |adj| options << adj } }
      #     after { options = [] }
      #     it "should choose a dark black synonym" do
      #       expect( [ [ @recipe.choose_color_adjective( :dark_black ) ] & options ][0] ).to be_truthy
      #     end
      #   end

      # end
    end

    describe "add_article" do
      context "with name \'ale\'" do
        before { @recipe.name = 'Ale' }
        it "should add \'An\'" do
          @recipe.add_article
          expect(@recipe.name).to eq( 'An Ale' )
        end
      end

      context "with \'Amber\'" do
        before { @recipe.name = "Amber" }
        it "should add \'An\'" do
          @recipe.add_article
          expect(@recipe.name).to eq( "An Amber" )
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

    describe "nationality_check" do
      before { allow(@recipe).to receive(:swap_yeast_adjective_order).and_return('Success!') }
      context "name includes German" do
        it "calls swap_yeast_adjective_order" do
          @recipe.name = 'Rye German Ale'
          @recipe.nationality_check
          expect(@recipe.name).to eq('Success!')
        end
      end
      context "name includes Belgian" do
        it "calls swap_yeast_adjective_order" do
          @recipe.name = 'Wheat Belgian Ale'
          @recipe.nationality_check
          expect(@recipe.name).to eq('Success!')
        end
      end
    end

    describe "swap_yeast_adjective_order" do
      it "moves the adjective to the front of the name string" do
        expect(@recipe.swap_yeast_adjective_order('White Hoppy Ale', 'Hoppy')).to eq('Hoppy White Ale')
      end
    end

  end