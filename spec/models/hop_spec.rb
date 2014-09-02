require 'rails_helper'

describe "Hop" do
  before { @hop = FactoryGirl.create(:hop) }

  subject { @hop }

  it { should respond_to(:name) }
  it { should respond_to(:alpha) }

  it { should be_valid }

  describe "with invalid attributes" do
    describe "with duplicate name" do
      it "should be invalid" do
        allow(@hop).to receive(:name).and_return("cascade")
        expect(@hop).not_to be_valid
      end
    end

    describe "with out of range alpha" do
      before { @hop.alpha = 0.0 }
      after { @hop.alpha = 5.5 }
      it { should_not be_valid }
    end
  end
end
