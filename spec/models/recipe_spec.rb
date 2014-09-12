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
      before { @recipe.generate_name("Porter") }
      it "should generate a name" do
        expect(@recipe.name).to eq("Porter")
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
        it "should choose quantities" do
          expect(malt.to_a[0][1]).to be_between(0.5, 15).inclusive
        end
      end

      describe "specialty malts" do
        describe "choose_specialty_malts" do
          it "should choose one specialty grain" do
            allow(@recipe).to receive(:num_specialty_malts).and_return(1)
            @recipe.assign_malts
            expect(@recipe.malts[:specialty].to_a[0][0]).to be_kind_of(Malt)
            expect(@recipe.malts[:specialty].to_a.length).to eq(1)
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
        before { @recipe.assign_yeast }

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
      @recipe.malts = { :base => malt_hash, :specialty => [ small_malt_hash ] }
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
      let(:hops) { { :bittering => { hop => [2, 60] }, :aroma => [{ hop => [1, 10] }] } }

      it "should calculate ibus" do
        @recipe.hops = hops
        @recipe.og = 1.040
        expect(@recipe.calc_ibu).to be_within(2).of(55)
        expect(@recipe.ibu).to be_within(2).of(55)
      end

      it "should calculate individual hop addition ibus" do
        @recipe.og = 1.040
        expect(@recipe.calc_indiv_ibu(hops[:bittering].to_a[0])).to be_within(0.01).of(50.59)
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
        expect(@recipe.display_hops).to eq("1.5 oz cascade test @ 60 min, 1.0 oz cascade test @ 10 min, 0.25 oz cascade test @ 5 min, ")
      end
    end

    describe "malt display helper" do
      let(:malt) { FactoryGirl.create(:malt) }
      before { @recipe.malts = { :base => { malt => 10 }, :specialty => [ { malt => 1 }, { malt => 0.5 } ] } }

      it "should return a display formatted list of malts" do
        expect(@recipe.display_malts).to eq("10 lb 2-row test, 1 lb 2-row test, 0.5 lb 2-row test, ")
      end
    end
  end

end
