require 'rails_helper'

describe "Malt" do
  before { @malt = FactoryGirl.create(:malt) }

  subject { @malt }

  it { should respond_to(:name) }
  it { should respond_to(:potential) }
  it { should respond_to(:malt_yield) }
  it { should respond_to(:srm) }
  it { should respond_to(:base_malt?) }
  it { should be_valid }

  describe "with invalid attributes" do

    describe "with duplicate name" do
      it "should be invalid" do
       allow(@malt).to receive(:name).and_return("2-row")
       expect(@malt).not_to be_valid
      end
    end

    describe "with out of range potential value" do
      before { @malt.potential = 1.080 }
      after { @malt.potential = 1.037 }
      it { should_not be_valid }
    end

    describe "with out of range malt_yield" do
      before { @malt.malt_yield = 1.2 }
      after { @malt.malt_yield = 0.8 }
      it { should_not be_valid }
    end

    describe "with out of range srm" do
      before { @malt.srm = 1100 }
      after { @malt.srm = 1.8 }
      it { should_not be_valid }
    end
  end

end
