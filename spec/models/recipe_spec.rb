require 'rails_helper'

describe "Recipe" do
  let(:recipe) { Recipe.new }

  subject  { recipe }

  it { should respond_to(:name) }
  it { should respond_to(:style) }
  it { should respond_to(:abv) }
  it { should respond_to(:ibu) }
  it { should respond_to(:srm) }
  it { should respond_to(:malts) }
  it { should respond_to(:hops) }
  it { should respond_to(:yeast) }

  describe "ingredient methods" do

    describe "name" do
      before { recipe.generate_name("Porter") }
      # placeholder test
      it "should generate a name" do
        expect(recipe.name).to eq("Porter")
      end
    end

    describe "malt" do

      let(:malt) { recipe.choose_malt(true) }

      describe "choose_malt" do
        it "should choose a malt" do
          expect(malt).not_to be_nil
        end
        it "should choose quantities" do
          expect(malt.to_a[0][1]).to be_between(0.5, 15).inclusive
        end
      end

      describe "assign malts" do
        before { recipe.assign_malts }

        subject { recipe.malts }

        it { should be_present }
        it { should have_key :base }
        it { should have_key :specialty }
        it "should assign base malts" do
          expect(recipe.malts[:base].to_a[0][0].base_malt?).to eq(true)
        end
        it "should assign specialty grains" do
          expect(recipe.malts[:specialty].to_a[0][0].base_malt?).to eq(false)
        end
      end
    end

    describe "hops" do

      let(:hop) { recipe.choose_hop }

      describe "choose_hop" do
        it "should choose a hop" do
          expect(hop).not_to be_nil
        end
        it "should choose quantities" do
          expect(hop.to_a[0][1]).to be_between(0.5, 3).inclusive
        end
      end

      describe "assign hops" do
        before { recipe.assign_hops }

        subject { recipe.hops }

        it { should be_present }
        it { should have_key :bittering }
        it { should have_key :aroma }
      end
    end

    describe "yeast" do

      let(:yeast) { recipe.choose_yeast }

      describe "choose_yeast" do
        it "should choose a yeast" do
          expect(yeast).not_to be_nil
        end
      end

      describe "assign yeast" do
        before { recipe.assign_yeast }

        it "should return a yeast" do
          expect(recipe.yeast).to be_present
        end
      end
    end

  end

  describe "calculations" do
    let(:malt) { FactoryGirl.create(:malt) }
    let(:malt_hash) { { malt => 10 } }
    let(:small_malt_hash) { { malt => 1 } }

    describe "original gravity calculations" do
      it "should convert potential gravity to extract potential" do
        expect(recipe.pg_to_ep(1.037)).to be_within(0.01).of(37)
      end

      it "should calculate original gravity" do
        expect(recipe.calc_og( malt_hash )).to eq(1.0592)
      end
    end

    describe "abv calculations" do
      before do
        recipe.yeast = FactoryGirl.create(:yeast)
        recipe.malts = { :base => malt_hash, :specialty => small_malt_hash }
      end

      it "should combine all original gravities" do
        expect(recipe.combine_og).to be_within(0.0001).of(1.0651)
        # high value from using malt_hash for both types
      end

      it "should calculate final gravity" do
        expect(recipe.calc_fg(1.0592)).to be_within(0.0001).of(1.0148)
        # fails due to yeast.attenuation?
      end

      it "should calculate abv" do
        expect(recipe.calc_abv).to be_within(0.01).of(6.39)
      end

      it "should assign abv" do
        recipe.calc_abv
        expect(recipe.abv).to be_within(0.01).of(6.39)
      end
    end
  end

end
