require 'rails_helper'

describe "Recipe" do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after { @recipe.destroy! }

  subject  { @recipe }

  it { should respond_to(:name) }
  it { should respond_to(:style) }
  it { should respond_to(:abv) }
  it { should respond_to(:ibu) }
  it { should respond_to(:srm) }
  it { should respond_to(:malts) }
  it { should respond_to(:hops) }
  it { should respond_to(:yeast) }
  it { should respond_to(:og) }

  it { should be_valid }

  describe "ingredient methods" do

    describe "name" do
      let(:style) { Style.find_by_name( "American IPA" ) }
      before do
        @recipe.style = style
      end

      it "should generate a name" do
        allow(@recipe).to receive(:pull_malt_name).and_return('2-row')
        @recipe.generate_name
        expect(@recipe.name).to eq("American IPA")
      end

      describe "positive smash_check" do
        # oops - put positive and negative in one 'describe'
        let(:single_malt)  { { :base => { Malt.find_by_name('maris otter') => 9 }, :specialty => {} } }
        let(:single_hop) { { :bittering => {  Hop.find_by_name('cascade') => [ 1.5, 60 ] }, :aroma=> [] } }
        before do
          @recipe.malts = single_malt
          @recipe.hops = single_hop
        end

        it "should identify SMASH beers" do
          @recipe.style = nil
          @recipe.generate_name
          expect(@recipe.name).to eq('Maris Otter Cascade SMASH')
        end

        it "should generate smash names" do
          @recipe.generate_smash_name
          expect(@recipe.name).to include('SMASH')
          expect(@recipe.name).to eq('Maris Otter Cascade SMASH')
        end
      end

      describe "negative smash_check" do
        let(:multi_malt) { { :base => { Malt.find_by_name('maris otter') => 9 }, :specialty => { Malt.find_by_name('carafa I') => 1, Malt.find_by_name('munich 10') => 0.75, Malt.find_by_name('black malt') => 1.75 } } }
        let(:single_hop) { { :bittering => {  Hop.find_by_name('amarillo') => [ 0.5, 60 ] }, :aroma=> [] } }

        before do
          @recipe.malts = multi_malt
          @recipe.hops = single_hop
        end

        it "should not identify as a smash beer" do
          expect(@recipe.name).not_to include("SMASH")
        end
      end

      describe "capitalize_titles" do
        it "should capitalize multi-word titles" do
          expect(@recipe.capitalize_titles('red wheat')).to eq('Red Wheat')
        end

        it "should capitalize one-word titles" do
          expect(@recipe.capitalize_titles('wheat')).to eq('Wheat')
        end
      end

      describe "name additions" do
        before do
          allow(@recipe).to receive(:pull_malt_name).and_return('white wheat')
          @recipe.generate_name
        end

        it "should add adjectives to the middle of two word names" do
          expect(@recipe.name).to eq( "American Wheat IPA" )
        end

        it "should add adjectives to the beginning of one word names" do
          @recipe.style = Style.find_by_name( 'Bock' )
          @recipe.generate_name
          expect(@recipe.name).to eq( 'Wheat Bock' )
        end

        it "should not add adjectives to styles which already include that adjunct" do
          @recipe.style = Style.find_by_name( 'Weizen' )
          @recipe.generate_name
          expect(@recipe.name).to eq('Weizen')
        end
      end
    end

    describe "malt" do

      describe "choose_malt" do
        before { @recipe.choose_malt(true) }
        let(:malt) { @recipe.malts[:base] }

        it "should choose a malt" do
          expect(malt).not_to be_nil
          expect(malt.to_a[0][0]).to be_kind_of(Malt)
        end
        it "should choose base malt quantities" do
          expect(malt.to_a[0][1]).to be_between(5, 15).inclusive
        end
      end

      describe "specialty malts" do
        describe "choose_specialty_malts" do
          before do
            allow(@recipe).to receive(:num_specialty_malts).and_return(1)
            @recipe.assign_malts
          end
          it "should choose one specialty grain" do
            expect(@recipe.malts[:specialty].to_a[0][0]).to be_kind_of(Malt)
            expect(@recipe.malts[:specialty].to_a.length).to eq(1)
          end

          it "should choose specialty malt quantities" do
            expect(@recipe.malts[:specialty].to_a[0][1]).to be_between(0.25, 2).inclusive
          end
        end

      end

      describe "assign malts" do
        before do
          allow(@recipe).to receive(:num_specialty_malts).and_return(1)
          @recipe.assign_malts
        end

        subject { @recipe.malts }

        it { should be_present }
        it { should have_key :base }
        it { should have_key :specialty }
        it "should assign base malts" do
          expect(@recipe.malts[:base].to_a[0][0].base_malt?).to eq(true)
        end
        it "should assign specialty grains" do
          expect(@recipe.malts[:specialty].to_a[0][0].base_malt?).to eq(false)
        end
      end
    end

    describe "hops" do

      let(:hop) { @recipe.choose_hop(true) }

      describe "choose_hop" do
        before { allow(@recipe).to receive(:num_aroma_hops).and_return(1) }
        let(:another_hop) { @recipe.choose_hop(false) }

        it "should choose a hop" do
          expect(hop).not_to be_nil
        end
        it "should choose quantities" do
          expect(hop.to_a[0][1][0]).to be_between(0.5, 3).inclusive
        end
        it "should choose appropriate bittering times" do
          expect(hop.to_a[0][1][1]).to be_between(40, 60).inclusive
        end
        it "should choose appropriate aroma times" do
          expect(another_hop.to_a[0][1][1]).to be_between(0, 30).inclusive
        end
      end

      describe "choose aroma hopping" do

        describe "choose number of aroma hops" do
          it "should choose some number of aroma hops" do
            expect(@recipe.num_aroma_hops).to be_between(0, 4).inclusive
          end
        end

        it "should choose one aroma hop" do
          allow(@recipe).to receive(:num_aroma_hops).and_return(1)
          expect(@recipe.choose_aroma_hops.length).to eq(1)
          # expect a one element array
        end

        it "should choose two aroma hops" do
          allow(@recipe).to receive(:num_aroma_hops).and_return(2)
          expect(@recipe.choose_aroma_hops.length).to eq(2)
          # expect a two element array
        end

        it "should choose no aroma hops" do
          allow(@recipe).to receive(:num_aroma_hops).and_return(0)
          expect(@recipe.choose_aroma_hops).to eq(nil)
          # expect nil
        end
      end

      describe "assign hops" do
        before do
          allow(@recipe).to receive(:num_aroma_hops).and_return(3)
          @recipe.assign_hops
        end

        subject { @recipe.hops }

        it { should be_present }
        it { should have_key :bittering }
        it { should have_key :aroma }
        it "should choose a bittering hop" do
          expect(@recipe.hops[:bittering].to_a[0][0]).to be_kind_of(Hop)
        end
        it "should choose an aroma hop" do
          expect(@recipe.hops[:aroma][0].to_a[0][0]).to be_kind_of(Hop)
        end
      end
    end

    describe "ingredient helper methods" do
      describe "hop array helpers" do
        before do
          allow(@recipe).to receive(:num_aroma_hops).and_return(2)
          @recipe.assign_hops
        end

        describe "hops_to_array" do
          it "should pull construct an array from @hops" do
            expect(@recipe.hops_to_array).to be_kind_of(Array)
          end
          it "should pull individual hop arrays from @hops" do
            expect(@recipe.hops_to_array[0][0]).to be_kind_of(Hop)
            # bittering hop
            expect(@recipe.hops_to_array[0][1][1]).to be_kind_of(Integer)
            # bittering time
            expect(@recipe.hops_to_array[2][0]).to be_kind_of(Hop)
            # 2nd aroma hop
          end

          describe "hop_names_to_array" do
            before do
              @recipe.hops = { :bittering => { Hop.find(1) => [2.5, 40] }, :aroma=> [ { Hop.find(2) => [2.0, 15] }, { Hop.find(3) => [3.0, 25] } ] }
            end
            it "should return a 1 dimensional array of all hops, names only" do
              expect(@recipe.hop_names_to_array).to eq([ 'cascade', 'centennial', 'hallertau' ])
            end
          end
        end

        describe "individual hop info" do
          let(:hop) { @recipe.hops[:bittering].to_a[0] }
          let(:hops_ary) { @recipe.hops_to_array }

          describe "pull_hop_object" do
            it "should return a hop object" do
              expect(@recipe.pull_hop_object(hops_ary[0])).to be_kind_of(Hop)
            end
          end

          describe "pull_hop_name" do
            it "should return a string" do
              expect(@recipe.pull_hop_name(hop)).to be_kind_of(String)
              expect(@recipe.pull_hop_name(hops_ary[1])).to be_kind_of(String)
            end
          end

          describe "pull_hop_amt" do
            it "should return an Float" do
              expect(@recipe.pull_hop_amt(hop)).to be_kind_of(Float)
              expect(@recipe.pull_hop_amt(hops_ary[0])).to be_kind_of(Float)
            end
          end

          describe "pull_hop_time" do
            it "should return a Integer" do
              expect(@recipe.pull_hop_time(hop)).to be_kind_of(Integer)
              expect(@recipe.pull_hop_time(hops_ary[2])).to be_kind_of(Integer)
            end
          end
        end
      end

      describe "malts array helpers" do
        before do
          allow(@recipe).to receive(:num_specialty_malts).and_return(1)
          @recipe.assign_malts
        end

        describe "malts_to_array" do
          it "should construct an array from @malts" do
            expect(@recipe.malts_to_array).to be_kind_of(Array)
          end
          it "should pull individual malt arrays from @malts" do
            expect(@recipe.malts_to_array[0][0]).to be_kind_of(Malt)
            # base malt
            expect(@recipe.malts_to_array[0][1]).to be_kind_of(Float)
            # base malt amount
          end
        end

        describe "individual malt info" do
          let(:malt) { @recipe.malts[:base].to_a[0] }
          let(:malt_ary) { @recipe.malts_to_array }

          describe "pull_malt_object" do
            it "should return a malt object" do
              expect(@recipe.pull_malt_object(malt_ary[0])).to be_kind_of(Malt)
            end
          end

          describe "pull_malt_name" do
            it "should return a string" do
              expect(@recipe.pull_malt_name(malt)).to be_kind_of(String)
              # expect(@recipe.pull_malt_name(malt_ary[0])).to be_kind_of(String)
            end
          end

          describe "pull_malt_amt" do
            it "should return a float" do
              expect(@recipe.pull_malt_amt(malt)).to be_kind_of(Float)
              # expect(@recipe.pull_malt_amt(malt_ary[0])).to be_kind_of(Float)
            end
          end
        end
      end
    end

    describe "yeast" do

      let(:yeast) { @recipe.choose_yeast }

      describe "choose_yeast" do
        it "should choose a yeast" do
          expect(yeast).not_to be_nil
        end
      end

      describe "assign yeast" do
        before do
          @recipe.assign_malts
          @recipe.assign_yeast
        end

        it "should return a yeast" do
          expect(@recipe.yeast).to be_present
        end

        describe "malt-yeast associations" do
          before do
            @recipe.malts[:base] = { Malt.find_by_name("pilsen") => 10 }
          end

          it "should pick an appropriate yeast for base malt" do
            expect(@recipe.associate_yeast.family).to eq("lager")
          end
        end
      end
    end

  end

  describe "calculations" do
    let(:malt) { Malt.find(1) }
    let(:malt_hash) { { malt => 10 } }
    let(:small_malt_hash) { { Malt.find(2) => 1 } }
    let(:malt_ary) { [ Malt.find(1), 10 ] }
    before do
      @recipe.yeast = FactoryGirl.create(:yeast)
      @recipe.malts = { :base => malt_hash, :specialty => small_malt_hash }
    end

    describe "original gravity calculations" do
      it "should convert potential gravity to extract potential" do
        expect(@recipe.pg_to_ep(1.037)).to be_within(0.01).of(37)
      end

      it "should calculate original gravity" do
        expect(@recipe.calc_og( malt_ary )).to be_within(0.0001).of(0.0592)
        # expect(@recipe.calc_og( { Malt.find(2) => 1 } )).to be_within(0.0001).of(0.004964)
      end
    end

    describe "abv calculations" do
      it "should combine all original gravities" do
        expect(@recipe.combine_og).to be_within(0.0001).of(0.06416)
        # high value from using malt_hash for both types
      end

      it "should calculate final gravity" do
        expect(@recipe.calc_fg(1.0592)).to be_within(0.0001).of(1.0148)
        # fails due to yeast.attenuation?
      end

      it "should calculate abv" do
        expect(@recipe.calc_abv).to be_within(0.1).of(6.3)
        expect(@recipe.abv).to be_within(0.1).of(6.3)
      end

    end

    describe "srm calculations" do
      it "should calculate mcu" do
        expect(@recipe.calc_mcu(malt_ary)).to be_within(0.1).of(3.6)
      end

      it "should add mcu from all malts" do
        expect(@recipe.combine_mcu).to be_within(0.1).of(15.6)
      end

      it "should calculate srm" do
        expect(@recipe.calc_srm).to be_within(0.01).of(9.91)
        expect(@recipe.srm).to be_within(0.01).of(9.91)
      end
    end

    describe "ibu calculations" do
      let(:hop) { FactoryGirl.create(:hop) }
      let(:hops) { { :bittering => { hop => [2, 60] }, :aroma => [ { hop => [1, 10] } ] } }

      it "should calculate ibus" do
        @recipe.hops = hops
        @recipe.og = 1.040
        # rager numbers:
        # expect(@recipe.calc_ibu).to be_within(2).of(55)
        # expect(@recipe.ibu).to be_within(2).of(55)
        # semi-tinseth numbers:
        expect(@recipe.calc_ibu).to be_within(2).of(45)
        expect(@recipe.ibu).to be_within(2).of(45)
      end

      it "should calculate individual hop addition ibus" do
        @recipe.og = 1.040
        # rager numbers:
        # expect(@recipe.calc_indiv_ibu(hops[:bittering].to_a[0])).to be_within(0.01).of(50.59)
        # semi-tinseth numbers:
        expect(@recipe.calc_indiv_ibu(hops[:bittering].to_a[0])).to be_within(0.01).of(39.46)
      end

      describe "Q&D rager to tinseth correction" do
        it "should use bittering percentage for times > 30 min" do
          expect(@recipe.rager_to_tinseth_q_and_d(60, 75)).to be_within(0.1).of(58.5)
        end

        it "should use aroma percentage for times <= 30 min" do
          expect(@recipe.rager_to_tinseth_q_and_d(30, 75)).to be_within(0.1).of(87)
        end
      end

      it "should calculate hop utilization" do
        expect(@recipe.calc_hop_util(60)).to be_within(0.0001).of(0.3082)
      end

      describe "gravity adjustments" do
        it "should return a gravity adjustment for og > 1.058" do
          @recipe.og = 1.059
          expect(@recipe.calc_hop_ga).to be_within(0.0001).of(0.005)
        end
        it "should return zero for og <= 1.058" do
          @recipe.og = 1.058
          expect(@recipe.calc_hop_ga).to eq(0)
        end
      end
    end

    describe "choose_attributes" do
      let(:another_recipe) { Recipe.new }
      before { another_recipe.choose_attributes }

      it "should populate instance variables with values" do
        expect(another_recipe.malts).to be_present
        expect(another_recipe.hops).to be_present
        expect(another_recipe.yeast).to be_present
        expect(another_recipe.og).to be_present
        expect(another_recipe.abv).to be_present
        expect(another_recipe.srm).to be_present
        expect(another_recipe.ibu).to be_present
        # expect(another_recipe.style).to be_present
      end
    end
  end

  describe "display helpers" do

    describe "hop display helper" do
      let(:hop) { FactoryGirl.create(:hop) }
      before { @recipe.hops = {:bittering => { hop => [1.5, 60] }, :aroma => [ { hop => [1.0, 10] }, { hop => [0.25, 5] } ] } }

      it "should return a display formatted list of hops" do
        expect(@recipe.display_hops).to eq("1.5 oz cascade test @ 60 min, 1.0 oz cascade test @ 10 min, 0.25 oz cascade test @ 5 min")
      end
    end

    describe "malt display helper" do
      let(:malt) { Malt.find(1) }
      let(:malt_1) { Malt.find(2) }
      let(:malt_2) { Malt.find(3) }
      before { @recipe.malts = { :base => { malt => 10 }, :specialty => { malt_1 => 1, malt_2 => 0.5 } } }

      it "should return a display formatted list of malts" do
        expect(@recipe.display_malts).to eq("10 lb 2-row, 1 lb caramel 60, 0.5 lb chocolate")
      end
    end
  end

  describe "style chooser" do
    let(:style) { Style.find_by_name( "American IPA" ) }
    let(:style_list) { [ style, Style.find_by_name( "American Stout" ) ] }
    let(:hop) { FactoryGirl.create(:hop) }
    before do
      @recipe.abv = 6
      @recipe.ibu = 60
      @recipe.srm = 10
      @recipe.yeast = Yeast.find_by_name('WY1056')
    end
    # strategy: each select method returns an array of all styles whose guidelines cover
    # supplied range.  Then all arrays are compared, and only duplicates are kept.
    # The remaining style is assigned to the recipe.
    # If no style matches, style will be default "a beer"
    # probably means resetting abv, ibu, srm as array types, not hash pairs  - done
    # also need to index anything you'll be searching (GIN?)
    # you need to be able to select styles by these values
    # Refactor later to include 'closest-to' calculations

    describe "select_by_yeast" do
      it "should return all styles whose yeast_family matches the supplied value" do
        expect(@recipe.select_by_yeast).to include( style )
        expect(@recipe.select_by_yeast).to include( Style.find_by_name("American Stout") )
      end
    end

    describe "select_by_aroma" do

      describe "recipe has aroma hops" do
        before { @recipe.hops = { :bittering => { hop => [2, 60] }, :aroma => [ { hop => [1, 10] } ] } }

        it "should return only a subset of styles which do require aroma hops" do
          expect(@recipe.select_by_aroma( style_list )).to eq( [ style ] )
        end
      end

      describe "recipe does not have aroma hops" do
        before { @recipe.hops = { :bittering => { hop => [2, 60] }, :aroma => nil } }

        it "should return the input array unchanged" do
          expect(@recipe.select_by_aroma( style_list )).to include( Style.find_by_name("American Stout") )
        end
      end
    end

    describe "select_by_malt" do
      let(:pilsner) { Style.find_by_name("Pilsner") }
      let(:style_list) { [ style, Style.find_by_name( "American Stout" ), pilsner ] }

      describe "recipe includes a malt required by a style" do
        before { @recipe.malts = { :base => { Malt.find_by_name( "pilsen" ) => 10 }, :specialty => {} } }

        it "should return the style which requires that malt" do
          expect(@recipe.select_by_malt(style_list)).to include( pilsner )
        end
      end

      describe "recipe does not include a malt required by a style" do
        before { @recipe.malts = { :base => { Malt.find_by_name( "2-row" ) => 10 }, :specialty => {} } }

        it "should NOT return the style which requires that malt" do
          expect(@recipe.select_by_malt(style_list)).not_to include( pilsner )
        end
      end
    end

    describe "select_by_abv" do
      it "should return a style whose range covers the supplied abv" do
        expect(@recipe.select_by_abv( style_list )).to include( style )
      end
      it "should return ALL styles whose range covers the supplied abv" do
        # test once there are multiple styles
      end
      it "should return ONLY styles whose range covers the supplied abv" do
        #  ditto
      end
    end

    describe "select_by_ibu" do
      it "should return a style whose range covers the supplied ibu" do
        expect(@recipe.select_by_ibu( style_list )).to include( style )
      end
      it "should return ALL styles whose range covers the supplied ibu" do
        # test once there are multiple styles
      end
      it "should return ONLY styles whose range covers the supplied ibu" do
        #  ditto
      end
    end

    describe "select_by_srm" do
      it "should return a style whose range covers the supplied srm" do
        expect(@recipe.select_by_srm( style_list )).to include( style )
      end
      it "should return ALL styles whose range covers the supplied srm" do
        # test once there are multiple styles
      end
      it "should return ONLY styles whose range covers the supplied srm" do
        expect(@recipe.select_by_srm( style_list )).not_to include( Style.find_by_name("American Stout") )
      end
    end

    describe "filter_possible_styles" do
      before { @recipe.hops = { :bittering => { hop => [2, 60] }, :aroma => [ { hop => [1, 10] } ] } }

      it "should return an array of only styles which match yeast, aroma, and malt stipulations, and abv, ibu, and srm ranges" do
        expect(@recipe.filter_possible_styles).to include( style )
        expect(@recipe.filter_possible_styles).not_to include( Style.find_by_name("American Stout") )
      end
    end

    describe "assign_style" do
      before { @recipe.hops = { :bittering => { hop => [2, 60] }, :aroma => [ { hop => [1, 10] } ] } }

      it "should assign a style" do
        @recipe.assign_style
        expect(@recipe.style).to eq( style )
      end

      describe "choose between overlapping styles" do
        before do
          # should fit both IPA and Pale
          @recipe.malts = { :base => { Malt.find_by_name("2-row") => 10 }, :specialty => { Malt.find_by_name("caramel 60") => 0.5 } }
          @recipe.hops = { :bittering => { Hop.find_by_name("cascade") => [2, 60] }, :aroma => [ { Hop.find_by_name("cascade") => [1, 5] } ] }
          @recipe.yeast = Yeast.find_by_name("WY1056")
          @recipe.calc_abv
          @recipe.calc_ibu
          @recipe.calc_srm
        end

        let(:style2) { Style.find_by_name("American Pale") }
        let(:two_styles) { [ style2, style ] }

        describe "tally_common_malts" do
          it "should return a tally of 1 for matching styles" do
            expect(@recipe.tally_common_malts( style  )).to eq( { style => 1 } )
            expect(@recipe.tally_common_malts( style2 )).to eq( { style2 => 1 } )
          end
        end

        describe "tally_common_hops" do
          it "should return a tally of 1 for matching styles" do
            expect(@recipe.tally_common_hops( style  )).to eq( { style => 1 } )
            expect(@recipe.tally_common_hops( style2 )).not_to eq( { style2 => 1 } )
          end
        end

        describe "tally_common_ingredients" do
          it "should return an array of two hashes with appropriate tally values" do
            expect(@recipe.tally_common_ingredients( two_styles )).to eq( [ { style2 => 1, style => 1 }, { style2 => 0, style => 1 } ] )
          end
        end

        describe "filter_style_by_ingredients" do
          it "should choose the style with the most matching 'common ingredients'" do
            expect(@recipe.filter_style_by_ingredients( two_styles )).to eq( Style.find_by_name("American IPA") )
          end
        end
      end
    end
  end
end
