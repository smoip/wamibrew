require 'rails_helper'

describe "Recipe" do
  before { @recipe = Recipe.new }

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

      let(:malt) { @recipe.choose_malt(true) }

      describe "choose_malt" do
        it "should choose a malt" do
          expect(malt).not_to be_nil
        end
        it "should choose quantities" do
          expect(malt.to_a[0][1]).to be_between(0.5, 15).inclusive
        end
      end

      describe "assign malts" do
        before { @recipe.assign_malts }

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
      let(:another_hop) { @recipe.choose_hop(false) }

      describe "choose_hop" do
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

      describe "assign hops" do
        before { @recipe.assign_hops }

        subject { @recipe.hops }

        it { should be_present }
        it { should have_key :bittering }
        it { should have_key :aroma }
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
    before do
      @recipe.yeast = FactoryGirl.create(:yeast)
      @recipe.malts = { :base => malt_hash, :specialty => small_malt_hash }
    end

    describe "original gravity calculations" do
      it "should convert potential gravity to extract potential" do
        expect(@recipe.pg_to_ep(1.037)).to be_within(0.01).of(37)
      end

      it "should calculate original gravity" do
        expect(@recipe.calc_og( malt_hash )).to be_within(0.0001).of(0.0592)
        expect(@recipe.calc_og( { Malt.find(2) => 1 } )).to be_within(0.0001).of(0.004964)
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
        expect(@recipe.calc_mcu(malt_hash)).to be_within(0.1).of(3.6)
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
      let(:hops) { { :bittering => { hop => [2, 60] }, :aroma => { hop => [1, 10] } } }

      it "should calculate ibus" do
        @recipe.hops = hops
        @recipe.og = 1.040
        expect(@recipe.calc_ibu).to be_within(2).of(55)
        expect(@recipe.ibu).to be_within(2).of(55)
      end

      it "should calculate individual hop addition ibus" do
        @recipe.og = 1.040
        expect(@recipe.calc_indiv_ibu(hops[:bittering])).to be_within(0.01).of(50.59)
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
  end

end
