require 'rails_helper'

describe "Yeast" do
  before { @yeast = Yeast.new }

  subject { @yeast }

  it { should respond_to(:name) }
  it { should respond_to(:type) }
  it { should respond_to(:attenuation) }
end
