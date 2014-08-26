require 'rails_helper'

describe "Recipe" do
  let(:recipe) { FactoryGirl.create(:recipe) }
  let(:malt)   { FactoryGirl.create(:malt) }
  let(:hop)    { FactoryGirl.create(:hop) }
  let(:yeast)  { FactoryGirl.create(:yeast) }

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
      it "should generate a name" do
        expect(recipe.name).to eq("Porter")
      end
    end

    describe "malt" do

      describe "choose_malt" do
        before do
          malt = recipe.choose_malt
        end
        it "should choose a malt" do
          expect(malt).not_to be_nil
        end
        it "should choose quantities" do
          expect(malt[malt.name]).to be_float
        end
      end

      describe "assign malts" do
        before { recipe.assign_malts }

        subject { recipe.malts }

        it { should be_present }
        it { should have_key :base }
        it { should have_key :specialty }
      end
    end

    describe "hops" do

      describe "choose_hops" do
        before do
          hop = recipe.choose_hop
        end
        it "should choose a hop" do
          expect(hop).not_to be_nil
        end
        it "should choose quantities" do
          expect(hop[hop.name]).to be_float
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

      describe "choose_yeast" do
        before do
          yeast = recipe.choose_yeast
        end
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

end
