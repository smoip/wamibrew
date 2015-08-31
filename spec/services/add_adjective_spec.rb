require 'service_objects_helper'

describe AddAdjective do
  include_context "shared service variables"

  describe "add_adjective" do
    let(:adjective_adder) { AddAdjective.new(@recipe.style) }
    context "with no style" do
      before { @recipe.style = nil }

      it "should prepend an adjective to the name" do
        expect(adjective_adder.add_adjective('Beer', 'Viscous')).to eq('Viscous Beer')
        # expect(@recipe.name).to eq('Viscous Beer')
      end
    end

    context "with assigned style" do
      before { @recipe.style = style }
      it "should insert an adjective between words in the name" do
        expect(adjective_adder.add_adjective('American IPA', 'Viscous')).to eq('American Viscous IPA')
        # expect(@recipe.name).to eq('American Viscous IPA')
      end
    end

    context "with protected name" do
      before { @recipe.style = Style.find_by_name('Pale Ale') }
      it "should insert the adjective before the protected name" do
        expect(adjective_adder.add_adjective('Pale Ale', 'Viscous')).to eq('Viscous Pale Ale')
        # expect(@recipe.name).to eq('Viscous Pale Ale')
      end
    end
  end

end