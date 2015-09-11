require 'service_objects_helper'

describe SelectByAroma do
  include_context "shared service variables"

  let(:by_aroma) { SelectByAroma.new(@recipe.hops) }

  describe "select" do
    let(:style_aroma_true) { FactoryGirl.build(:style, name: 'aroma needed', aroma_required?: true) }
    let(:style_aroma_false) { FactoryGirl.build(:style, name: 'aroma not needed', aroma_required?: false) }
    let(:style_list_1) { [ style_aroma_true, style_aroma_false ] }
    context "style_list includes aroma required style, aroma hops not present" do
      before { allow(by_aroma).to receive(:aroma_present?).and_return(false) }
      it "returns at least one style" do
        expect(by_aroma.select(style_list_1)).not_to eq([])
      end
      it "returns only aroma not required styles" do
        expect(by_aroma.select(style_list_1)).not_to include(style_aroma_true)
      end
    end
    context "style_list includes aroma required style, aroma hops present" do
      it "returns at least one style" do
        expect(by_aroma.select(style_list_1)).not_to eq([])
      end
      it "returns both aroma required styles and aroma not required styles" do
        allow(by_aroma).to receive(:aroma_present?).and_return(true)
        expect(by_aroma.select(style_list_1)).to (include(style_aroma_true) && include(style_aroma_false))
      end
    end
    context "style_list does not include aroma required style, aroma hops not present" do
      before { allow(by_aroma).to receive(:aroma_present?).and_return(false) }
      it "returns at least one style" do
        style_list_1 = [ style_aroma_false ]
        expect(by_aroma.select(style_list_1)).not_to eq([])
      end
      it "returns only aroma not required styles" do
        style_list_1 = [ style_aroma_false ]
        expect(by_aroma.select(style_list_1)).not_to include(style_aroma_true)
      end
    end
    context "style_list does not include aroma required style, aroma hops present" do
      before { allow(by_aroma).to receive(:aroma_present?).and_return(true) }
      it "returns at least one style" do
        style_list_1 = [ style_aroma_false ]
        expect(by_aroma.select(style_list)).not_to eq([])
      end
      it "returns only aroma not required styles" do
        style_list_1 = [ style_aroma_false ]
        expect(by_aroma.select(style_list_1)).not_to include(style_aroma_true)
      end
    end
  end

  describe "aroma_present?" do
    context "aroma hops present" do
      it "returns true" do
        by_aroma.hops[:aroma]= [ { hop => [ 1.25, 20 ] } ]
        expect(by_aroma.aroma_present?).to be(true)
      end
    end
    context "aroma hops not present" do
      it "returns false" do
        by_aroma.hops[:aroma]= []
        expect(by_aroma.aroma_present?).to be(false)
      end
    end
  end

end