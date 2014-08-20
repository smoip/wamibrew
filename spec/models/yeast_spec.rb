require 'rails_helper'

describe "Yeast" do
  before { @yeast = Yeast.new }

  subject { @yeast }

  it { should respond_to(:name) }
  it { should respond_to(:family) }
  it { should respond_to(:attenuation) }
end
