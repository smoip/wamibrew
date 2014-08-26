require 'rails_helper'

describe "Malt" do
  let(:malt) { FactoryGirl.create(:malt) }

  subject { malt }

  it { should respond_to(:name) }
  it { should respond_to(:potential) }
  it { should respond_to(:malt_yield) }
  it { should respond_to(:srm) }
  it { should respond_to(:base_malt?) }

end
