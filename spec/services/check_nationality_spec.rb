require 'service_objects_helper'

describe CheckNationality do
  include_context "shared service variables"
  let(:nationality) { CheckNationality.new(@recipe.name) }

  describe "nationality_check" do
    before { allow(nationality).to receive(:swap_yeast_adjective_order).and_return('Success!') }
    context "name includes German" do
      it "calls swap_yeast_adjective_order" do
        nationality.name = 'Rye German Ale'
        expect(nationality.check).to eq('Success!')
      end
    end
    context "name includes Belgian" do
      it "calls swap_yeast_adjective_order" do
        nationality.name = 'Wheat Belgian Ale'
        expect(nationality.check).to eq('Success!')
      end
    end
  end

  describe "swap_yeast_adjective_order" do
    it "moves the adjective to the front of the name string" do
      expect(nationality.swap_yeast_adjective_order('White Hoppy Ale', 'Hoppy')).to eq('Hoppy White Ale')
    end
  end
end