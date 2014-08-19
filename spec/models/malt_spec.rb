require 'rails_helper'

describe "Malt" do
  before { @malt = Malt.new }

  subject { @malt }

  it { should respond_to(:name) }
  it { should respond_to(:potential) }
  it { should respond_to(:yield) }
  it { should respond_to(:srm) }

end
