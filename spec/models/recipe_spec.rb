require 'rails_helper'

describe Recipe do
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
  it { should respond_to(:stack_token)}

  it { should be_valid }

  describe "ingredient methods" do

    describe "name" do
      let(:style) { Style.find_by_name( "IPA" ) }
      before do
        @recipe.style = style
      end

      it "should generate a name" do
        allow(@recipe).to receive(:pull_malt_name).and_return('2-row')
        @recipe.generate_name
        expect(@recipe.name).to eq("An IPA")
      end

      describe "smash_check" do
        let(:single_malt)  { { :base => { Malt.find_by_name('maris otter') => 9 }, :specialty => {} } }
        let(:single_hop) { { :bittering => {  Hop.find_by_name('cascade') => [ 1.5, 60 ] }, :aroma=> [] } }
        let(:multi_malt) { { :base => { Malt.find_by_name("2-row") => 10 }, :specialty => { Malt.find_by_name("caramel 60") => 0.5 } } }
        let(:multi_hop) { @recipe.hops = { :bittering => { Hop.find_by_name("cascade") => [2, 60] }, :aroma => [ { Hop.find_by_name("centennial") => [1, 5] } ] } }
        before { @recipe.yeast = Yeast.find_by_name( "WY1056 - American Ale" ) }

        describe "positively identify SMASH beers" do
          before do
            @recipe.malts = single_malt
            @recipe.hops = single_hop
            @recipe.style = nil
          end

          describe "generate_smash_name" do
            it "should generate smash names" do
              expect(@recipe.generate_smash_name).to include('SMASH')
              expect(@recipe.generate_smash_name).to eq('Maris Otter Cascade SMASH')
            end
          end

          it "should identify SMASH beers" do
            @recipe.generate_name
            expect(@recipe.name).to eq('A Maris Otter Cascade SMASH')
          end
        end

        describe "negatively identify SMASH beers" do
          before { allow(@recipe).to receive(:yeast).and_return( Yeast.find_by_name( "WY1056 - American Ale" ) ) }
          before { allow(@recipe).to receive(:rand).and_return( 2 ) }
          context "with multiple malts, single hop" do
            before do
              @recipe.malts = multi_malt
              @recipe.hops = single_hop
              @recipe.style = nil
            end

            it "should not identify as a smash beer" do
              @recipe.generate_name
              expect(@recipe.name).not_to include("SMASH")
            end
          end

          context "with single malts, multiple hops" do
            before do
              @recipe.malts = single_malt
              @recipe.hops = multi_hop
              @recipe.style = nil
            end

            it "should not identify as a smash beer" do
              @recipe.generate_name
              expect(@recipe.name).not_to include("SMASH")
            end
          end
        end

      end

      describe "name additions" do

        describe "adjunct adjectives" do
          describe "by base malt" do
            before do
              allow(@recipe).to receive(:pull_malt_name).and_return('white wheat')
              allow(@recipe).to receive(:one_of_four).and_return(2)
              @recipe.generate_name
            end

            it "should add adjectives to the middle of two word names" do
              expect(@recipe.name).to eq( "A Wheat IPA" )
            end

            it "should add adjectives to the beginning of one word names" do
              @recipe.style = Style.find_by_name( 'Bock' )
              @recipe.generate_name
              expect(@recipe.name).to eq( 'A Wheat Bock' )
            end

            it "should not add adjectives to styles which already include that adjunct" do
              @recipe.style = Style.find_by_name( 'Weizen' )
              @recipe.generate_name
              expect(@recipe.name).to eq('A Weizen')
            end
          end

          describe "by specialty malt" do
            let(:with_rye) { { :base => { Malt.find_by_name("2-row") => 10 }, :specialty => { Malt.find_by_name("rye malt") => 1 } } }
            before { allow(@recipe).to receive(:one_of_four).and_return(2) }

            it "should add an adjunct from the specialty malts" do
              @recipe.malts = with_rye
              @recipe.style = Style.find_by_name("Pale Ale")
              @recipe.name = "Pale Ale"
              @recipe.add_ingredient_to_name
              expect(@recipe.name).to eq("Rye Pale Ale")
            end
          end

          describe "by SMASH determination" do
            it "should not add repetitive adjectives to SMASH beers" do
              @recipe.malts = { :base => { Malt.find_by_name('white wheat') => 9 }, :specialty => {} }
              @recipe.hops = { :bittering => {  Hop.find_by_name('cascade') => [ 1.5, 60 ] }, :aroma=> [] }
              @recipe.style = nil
              @recipe.generate_name
              expect(@recipe.name).not_to include("Wheat Wheat")
            end
          end
        end

        describe "by yeast type" do
          context "ale" do
            before do
              @recipe.style = nil
              @recipe.yeast = Yeast.find_by_name("WY1056 - American Ale")
              allow(@recipe).to receive(:rand).and_return(1)
            end

            it "should replace 'Beer' with 'Ale'" do
              @recipe.add_yeast_family
              expect(@recipe.name).to include("Ale")
            end
          end
          context "lager" do
            before do
              @recipe.style = nil
              @recipe.yeast = Yeast.find_by_name("WY2001 - Urqell Lager")
              allow(@recipe).to receive(:rand).and_return(1)
            end

            it "should replace 'Beer' with 'Lager'" do
              @recipe.add_yeast_family
              expect(@recipe.name).to include("Lager")
            end
          end
        end

        describe "nationality_check" do
          context "name includes German" do
            it "moves \'German\' to the front of the name string" do
              @recipe.name = 'Rye German Ale'
              @recipe.nationality_check
              expect(@recipe.name).to eq('German Rye Ale')
            end
          end
          context "name includes Belgian" do
            it "moves \'Belgian\' to the front of the name string" do
              @recipe.name = 'Wheat Belgian Ale'
              @recipe.nationality_check
              expect(@recipe.name).to eq('Belgian Wheat Ale')
            end
          end
        end

        describe "by hoppiness" do
          pending
        end
      end
    end

    describe "malt" do
      describe "assign malts" do
        before do
          # needs to be properly stubbed at service object...
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
      describe "assign hops" do
        context "choose three aroma additions" do
          before do
            # needs to be properly stubbed at service object
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
          it "should have three aroma hops" do
            expect(@recipe.hops[:aroma].length).to eq(3)
          end
        end
        context "choose zero aroma hop additions" do
          before do
            # needs to be properly stubbed at service object
            allow(@recipe).to receive(:num_aroma_hops).and_return(0)
            @recipe.assign_hops
          end
          it "should have no aroma hops" do
            expect(@recipe.hops[:aroma].length).to eq(0)
          end
        end
      end
    end

    describe "ingredient helper methods" do
      describe "hop array helpers" do
        before do
          # needs to properly stubbed at service object
          allow(@recipe).to receive(:num_aroma_hops).and_return(2)
          @recipe.assign_hops
        end

        describe "hops_to_array" do
          it "should construct an array from @hops" do
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
            end
          end

          describe "pull_malt_amt" do
            it "should return a float" do
              expect(@recipe.pull_malt_amt(malt)).to be_kind_of(Float)
            end
          end
        end
      end
    end

    describe "yeast" do

      let(:yeast) { FactoryGirl.build(:yeast) }

      describe "assign yeast" do
        before do
          @recipe.yeast = nil
          @recipe.assign_malts
          @recipe.assign_yeast
        end

        it "should return a yeast" do
          expect(@recipe.yeast).to be_present
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

    describe "abv calculations" do

      it "should calculate abv" do
        @recipe.calc_gravities
        expect(@recipe.abv).to be_within(0.1).of(6.3)
      end

    end

    describe "color assignment" do
      it "should calculate srm" do
        expect(@recipe.calc_color).to be_within(0.01).of(9.91)
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
        # @recipe.calc_bitterness
        # expect(@recipe.ibu).to be_within(2).of(55)
        # semi-tinseth numbers:
        @recipe.calc_bitterness
        expect(@recipe.ibu).to be_within(2).of(45)
      end

    end

    describe "choose_attributes" do
      let(:another_recipe) { Recipe.new }
      before { another_recipe.choose_attributes }

      it "should populate instance variables with values" do
        expect(another_recipe.malts).to be_present
        expect(another_recipe.malts[:base].to_a.flatten[0]).to be_kind_of(Malt)
        expect(another_recipe.hops).to be_present
        expect(another_recipe.hops[:bittering].to_a.flatten[0]).to be_kind_of(Hop)
        expect(another_recipe.yeast).to be_present
        expect(another_recipe.og).to be_present
        expect(another_recipe.abv).to be_present
        expect(another_recipe.srm).to be_present
        expect(another_recipe.ibu).to be_present
      end
    end
  end

  describe "display helpers" do

    describe "hop display helper" do
      let(:hop) { FactoryGirl.create(:hop) }

      describe "display_hops" do
        before { @recipe.hops = {:bittering => { hop => [1.5, 60] }, :aroma => [ { hop => [1.0, 10] }, { hop => [0.25, 5] } ] } }

        it "should return a display formatted list of hops" do
          expect(@recipe.display_hops).to eq("1.5 oz cascade test @ 60 min, 1.0 oz cascade test @ 10 min, 0.25 oz cascade test @ 5 min")
        end
      end

      describe "order_hops" do
        before { @recipe.hops = {:bittering => { hop => [1.5, 60] }, :aroma => [ { hop => [1.0, 5] }, { hop => [0.25, 10] } ] } }

        describe "flat_hops_array" do
          it "should return a flattened array format [ time, [<hop>, amt] ]" do
            expect(@recipe.flat_hops_array[0]).to eq( [ 60, [ hop, 1.5 ] ] )
          end
        end

        it "should return an addition-time ordered list of hops" do
          expect(@recipe.display_hops).to eq("1.5 oz cascade test @ 60 min, 0.25 oz cascade test @ 10 min, 1.0 oz cascade test @ 5 min")
        end
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

  describe "style determination" do
    let(:style) { Style.find_by_name( "IPA" ) }
    let(:stout) { Style.find_by_name( "Stout" ) }
    let(:style_list) { [ style, stout ] }
    let(:hop) { FactoryGirl.create(:hop) }
    before do
      @recipe.abv = 6
      @recipe.ibu = 60
      @recipe.srm = 10
      @recipe.yeast = Yeast.find_by_name('WY1056 - American Ale')
      style_list = [ style ]
    end
    # need to index anything you'll be searching (GIN?)
    # you need to be able to select styles by these values
    # Refactor later to include 'closest-to' calculations

    describe "select_by_yeast" do
      it "should return all styles whose yeast_family matches the supplied value" do
        expect(@recipe.select_by_yeast).to include( style )
        expect(@recipe.select_by_yeast).to include( stout )
      end
    end

    describe "select_by_aroma" do

      describe "recipe has aroma hops" do
        before { @recipe.hops = { :bittering => { hop => [2, 60] }, :aroma => [ { hop => [1, 10] } ] } }

        it "should return the input array unchanged" do
          expect(@recipe.select_by_aroma( style_list )).to include( stout )
        end
      end

      describe "recipe does not have aroma hops" do
        before { @recipe.hops = { :bittering => { hop => [2, 60] }, :aroma => [] } }

        it "should return return a subset minus styles which require aroma hops" do
          expect(@recipe.select_by_aroma( style_list )).not_to include( style )
        end
      end
    end

    describe "select_by_malt" do
      let(:pilsner) { Style.find_by_name("Pilsner") }
      let(:style_list) { [ style, stout, pilsner ] }

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
      it "should return ALL styles whose range covers the supplied ibu"
        # test once there are multiple styles
      it "should return ONLY styles whose range covers the supplied ibu"
        #  ditto
    end

    describe "select_by_srm" do
      it "should return a style whose range covers the supplied srm" do
        expect(@recipe.select_by_srm( style_list )).to include( style )
      end
      it "should return ALL styles whose range covers the supplied srm" do
        # test once there are multiple styles
      end
      it "should return ONLY styles whose range covers the supplied srm" do
        expect(@recipe.select_by_srm( style_list )).not_to include( stout )
      end
    end

    describe "filter_possible_styles" do
      before { @recipe.hops = { :bittering => { hop => [2, 60] }, :aroma => [ { hop => [1, 10] } ] } }

      it "should return an array of only styles which match yeast, aroma, and malt stipulations, and abv, ibu, and srm ranges" do
        expect(@recipe.filter_possible_styles).to include( style )
        expect(@recipe.filter_possible_styles).not_to include( stout )
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
          @recipe.yeast = Yeast.find_by_name("WY1056 - American Ale")
          @recipe.calc_gravities
          @recipe.calc_bitterness
          @recipe.calc_color
        end

        let(:style2) { Style.find_by_name("Pale Ale") }
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
            expect(@recipe.filter_style_by_ingredients( two_styles )).to eq( Style.find_by_name("IPA") )
          end
        end
      end
    end
  end
end
