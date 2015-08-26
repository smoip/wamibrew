require 'service_objects_helper'

describe ReAssignHops do
  include_context "shared service variables"
  let(:re_hop) { ReAssignHops.new(@recipe) }

  describe "extreme_ibu_check" do
    before { allow(re_hop).to receive(:re_assign_hops).and_return('success') }
    context "ibus > 120" do
      before { @recipe.ibu = 124 }
      it "attempts to reassign hops" do
        expect(re_hop.extreme_ibu_check).to eq('success')
      end
    end

    context "ibus < 120" do
      before { @recipe.ibu = 15 }
      it "does not attempt to resassign hops" do
        expect(re_hop.extreme_ibu_check).not_to eq('success')
      end
    end
  end

  describe "ibu_gravity_check" do
    before { allow(re_hop).to receive(:re_assign_hops).and_return('assigning hops...') }
    context "abv <= 4.5 && ibu > 60" do
      before do
        @recipe.abv = 3.0
        @recipe.ibu = 72
      end
      it "should reassign hops" do
        expect(re_hop.ibu_gravity_check).to eq('assigning hops...')
      end
    end
    context "abv <=  6.0 && ibu > 90" do
      before do
        @recipe.abv = 5.2
        @recipe.ibu = 99
      end
      it "should reassign hops" do
        expect(re_hop.ibu_gravity_check).to eq('assigning hops...')
      end
    end
    context "abv > 4.5 && ibu > 60" do
      before do
        @recipe.abv = 4.6
        @recipe.ibu = 80
      end
      it "should not reassign hops" do
        expect(re_hop.ibu_gravity_check).not_to eq('assigning hops...')
      end
    end
    context "abv <= 4.5 && ibu < 60" do
      before do
        @recipe.abv = 3.1
        @recipe.ibu = 55
      end
      it "should not reassign hops" do
        expect(re_hop.ibu_gravity_check).not_to eq('assigning hops...')
      end
    end
  end

  describe "re_assign_hops" do
    before do
      allow(re_hop).to receive(:ibu_gravity_check).and_return('gravity check')
      allow(re_hop).to receive(:extreme_ibu_check).and_return('gravity check')
      allow(@recipe).to receive(:assign_hops).and_return(nil)
      allow(@recipe).to receive(:calc_bitterness).and_return(nil)
    end
    context "stack_token > 15" do
      before { @recipe.stack_token = 16 }
      it "should not run ibu/gravity checks" do
        expect(re_hop.re_assign_hops).not_to eq('gravity check')
      end
    end

    context "stack_token <= 15" do
      before { @recipe.stack_token = 14 }
      it "should run ibu/gravity comparisons" do
        expect(re_hop.re_assign_hops).to eq('gravity check')
      end
    end
  end
end