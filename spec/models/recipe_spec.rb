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
      let(:style) { Style.find_by_name("IPA") }
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
        before { @recipe.yeast = Yeast.find_by_name("WY1056 - American Ale") }

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
          before { allow(@recipe).to receive(:yeast).and_return(Yeast.find_by_name("WY1056 - American Ale")) }
          before { allow(@recipe).to receive(:rand).and_return(2) }
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
              expect(@recipe.name).to eq("A Wheat IPA")
            end

            it "should add adjectives to the beginning of one word names" do
              @recipe.style = Style.find_by_name('Bock')
              @recipe.generate_name
              expect(@recipe.name).to eq('A Wheat Bock')
            end

            it "should not add adjectives to styles which already include that adjunct" do
              @recipe.style = Style.find_by_name('Weizen')
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

      describe "add_article" do
        context "with name \'ale\'" do
          before { @recipe.name = 'Ale' }
          it "should add \'An\'" do
            @recipe.add_article
            expect(@recipe.name).to eq('An Ale')
          end
        end

        context "with \'Amber\'" do
          before { @recipe.name = "Amber" }
          it "should add \'An\'" do
            @recipe.add_article
            expect(@recipe.name).to eq("An Amber")
          end
        end

        context "with other vowel-start name" do
          before { @recipe.name  = "Imperial Stout" }
          it "should add \'An\'" do
            @recipe.add_article
            expect(@recipe.name).to eq("An Imperial Stout")
          end
        end

        context "with vowel-start and extra whitespace" do
          before { @recipe.name = " Ale" }
          it "should add \'An\'" do
            @recipe.add_article
            expect(@recipe.name).to eq("An Ale")
          end
        end

        context "with consonant-start" do
          before { @recipe.name = "Session IPA" }
          it "should add \'A\'" do
            @recipe.add_article
            expect(@recipe.name).to eq("A Session IPA")
          end
        end
      end
    end

    describe "malt" do
      let(:malt) { FactoryGirl.build(:malt) }
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

      describe "store_malt" do
        context "malt is not already present in recipe" do
          before do
            @recipe.malts = { :base => {}, :specialty => {} }
            @recipe.store_malt([:base, malt, 2.11])
          end
          it "creates a new entry for this malt in the malt hash according to key" do
            expect(@recipe.malts[:base]).to eq({ malt => 2.11 })
          end
          it "does not add this malt to the wrong key in the malt hash" do
            expect(@recipe.malts[:specialty]).not_to eq({ malt => 2.11 })
          end
        end

        context "malt is already present in recipe" do
          before do
            @recipe.malts[:specialty] = { malt => 1 }
            @recipe.store_malt([:specialty, malt, 3.0])
          end
          it "adds this malt to the existing entry in the malt hash" do
            expect(@recipe.malts[:specialty]).to eq({ malt => 4.0 })
          end
          it "does not create a new entry for this malt in the malt hash" do
            expect(@recipe.malts[:base]).not_to eq({ malt => 3.0 })
          end
        end
      end
    end

    describe "hops" do
      let(:hop) { FactoryGirl.build(:hop) }
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

      describe "store_hop" do
        context "type == bittering" do
          before do
            @recipe.hops = { :bittering => {}, :aroma => [] }
            @recipe.store_hop([:bittering, hop, 2.0, 60])
          end
          it "stores a bittering hop" do
            expect(@recipe.hops[:bittering]).to eq({ hop => [ 2.0, 60 ] })
          end
        end
        context "type == aroma" do
          it "stores the first aroma hop" do
            @recipe.hops = { :bittering => {}, :aroma => [] }
            @recipe.store_hop([:aroma, hop, 2.0, 10])
            expect(@recipe.hops[:aroma]).to eq([ { hop => [ 2.0, 10 ] } ])
          end
          it "stores subsequent aroma hops" do
            @recipe.hops = { :bittering => {}, :aroma => [ { hop => [ 1.5, 5 ] } ] }
            @recipe.store_hop([:aroma, hop, 2.0, 10])
            expect(@recipe.hops[:aroma]).to eq([ { hop => [ 1.5, 5 ] }, { hop => [ 2.0, 10 ] } ])
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
            expect(@recipe.flat_hops_array[0]).to eq([ 60, [ hop, 1.5 ] ])
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
    let(:style) { FactoryGirl.build(:style) }
    let(:style_b) { FactoryGirl.build(:style, name: 'another style') }
    let(:style_list) { [ style, style_b ] }

    describe "filter_possible_styles" do
      before do
        allow(@recipe).to receive(:select_by_yeast).and_return(nil)
        allow(@recipe).to receive(:select_by_malt).and_return(nil)
      end
      context "no style by aroma, malt, or yeast" do
        before { allow(@recipe).to receive(:select_by_aroma).and_return([]) }
        it "returns an empty array" do
          expect(@recipe.filter_possible_styles).to eq([])
        end
      end
      context "possible styles by aroma, malt, and yeast" do
        before do
          allow(@recipe).to receive(:select_by_aroma).and_return( style_list )
          allow(@recipe).to receive(:select_by_abv).and_return([ style ])
        end
        context "one of three matches" do
          it "returns an empty array" do
            expect(@recipe.filter_possible_styles).to eq([])
          end
        end
        context "two of three matches" do
          it "returns an empty array" do
            allow(@recipe).to receive(:select_by_ibu).and_return([ style ])
            expect(@recipe.filter_possible_styles).to eq([])
          end
        end
        context "all three matches, one possible style" do
          it "returns a style" do
            allow(@recipe).to receive(:select_by_ibu).and_return([ style ])
            allow(@recipe).to receive(:select_by_srm).and_return([ style ])
            expect(@recipe.filter_possible_styles).to eq([ style ])
          end
        end
        context "all three matches, multiple possible styles" do
          it "returns multiple styles" do
            allow(@recipe).to receive(:select_by_abv).and_return( style_list )
            allow(@recipe).to receive(:select_by_ibu).and_return( style_list )
            allow(@recipe).to receive(:select_by_srm).and_return( style_list )
            expect(@recipe.filter_possible_styles).to eq( style_list )
          end
        end
      end
    end

    describe "assign_style" do
      context "no style matches" do
        before { allow(@recipe).to receive(:filter_possible_styles).and_return([]) }
        it "does not assign a style" do
          @recipe.assign_style
          expect(@recipe.style).to eq(nil)
        end
      end
      context "one possible style" do
        before { allow(@recipe).to receive(:filter_possible_styles).and_return([style]) }
        it "assigns that style" do
          @recipe.assign_style
          expect(@recipe.style).to eq(style)
        end
      end
      context "multiple possible styles" do
        before do
          allow(@recipe).to receive(:filter_possible_styles).and_return(style_list)
          allow(@recipe).to receive(:filter_style_by_ingredients).and_return(style)
        end
        it "assigns a style" do
          @recipe.assign_style
          expect(@recipe.style).to eq(style)
        end
      end
    end
  end
end
