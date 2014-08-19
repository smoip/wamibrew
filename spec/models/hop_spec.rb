require 'rails_helper'

describe "Hop" do
  before { @hop = Hop.new }

  subject { @hop }

  it { should respond_to(:name) }
  it { should respond_to(:alpha) }
end
