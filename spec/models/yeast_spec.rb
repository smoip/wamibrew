require 'rails_helper'

describe "Yeast" do
  before { @yeast = FactoryGirl.create(:yeast) }

  subject { @yeast }

  it { should respond_to(:name) }
  it { should respond_to(:family) }
  it { should respond_to(:attenuation) }

  it { should be_valid }

  describe "with invalid attributes" do
    describe "with duplicate name" do
      it "should be invalid" do
        allow(@yeast).to receive(:name).and_return("WY1056")
        expect(@yeast).not_to be_valid
      end
    end

    describe "with out of range attenuation" do
      before { @yeast.attenuation = 50 }
      after { @yeast.attenuation = 75 }
      it { should_not be_valid }
    end
  end
end
