require 'service_objects_helper'

describe AssignMalts do
  include_context "shared service variables"
  let(:maltster) { AssignMalts.new(@recipe) }

  describe "choose_malt" do
    before do
      @recipe.malts = { :base => {}, :specialty => {} }
      maltster.choose_malt(true)
    end
    let(:malt_array) { @recipe.malts[:base] }

    it "should choose a malt" do
      expect(malt_array).not_to be_nil
      expect(malt_array.to_a[0][0]).to be_kind_of(Malt)
    end
    it "should choose base malt quantities" do
      expect(malt_array.to_a[0][1]).to be_between(5, 15).inclusive
    end
  end

  describe "num_specialty_malts" do
    it "should pick 0..1" do
      allow(maltster).to receive(:rand).and_return(0)
      expect(maltster.num_specialty_malts).to be_between(0, 1).inclusive
    end

    it "should pick 1..2" do
      allow(maltster).to receive(:rand).and_return(1)
      expect(maltster.num_specialty_malts).to be_between(1, 2).inclusive
    end

    it "should pick 1..3" do
      allow(maltster).to receive(:rand).and_return(2)
      expect(maltster.num_specialty_malts).to be_between(1, 3).inclusive
    end

    it "should pick 2..4" do
      allow(maltster).to receive(:rand).and_return(3)
      expect(maltster.num_specialty_malts).to be_between(2, 4).inclusive
    end

    it "should pick 3..5" do
      allow(maltster).to receive(:rand).and_return(4)
      expect(maltster.num_specialty_malts).to be_between(3, 5).inclusive
    end
  end

  describe "malt_type_to_key" do
    context "type = true" do
      it "should return :base" do
        expect(maltster.malt_type_to_key(true)).to eq(:base)
      end
    end

    context "type = false" do
      it "should return :specialty" do
        expect(maltster.malt_type_to_key(false)).to eq(:specialty)
      end
    end
  end

  describe "store_malt" do
    context "malt is not already present in recipe" do
      before do
        @recipe.malts = { :base => {}, :specialty => {} }
        allow(maltster).to receive(:malt_amount).and_return(2.11)
        maltster.store_malt(:base, malt)
      end
      it "creates a new entry for this malt in the malt hash according to key" do
        expect(@recipe.malts[:base]).to eq({ malt => 2.11 })
      end
      it "does not add this malt to the wrong key in the malt hash" do
        expect(@recipe.malts[:specialty]).not_to eq({ malt => 2.11 })
      end
    end

    context "malt is already present in recipe" do
      before do
        @recipe.malts[:specialty] = { malt => 1 }
        allow(maltster).to receive(:malt_amount).and_return(3.0)
        maltster.store_malt(:specialty, malt)
      end
      it "adds this malt to the existing entry in the malt hash" do
        expect(@recipe.malts[:specialty]).to eq({ malt => 4.0 })
      end
      it "does not create a new entry for this malt in the malt hash" do
        expect(@recipe.malts[:base]).not_to eq({ malt => 3.0 })
      end
    end
  end

  describe "order_specialty_malts"do
    context "no specialty malts" do
      before { @recipe.malts[:specialty]= {} }
      it "assigns an empty hash" do
        maltster.order_specialty_malts
        expect(@recipe.malts[:specialty]).to eq({})
      end
    end
    context "specialty malts present" do
      before { @recipe.malts[:specialty]= { malt => 2, malt_1 => 2.25, malt_2 => 0.5 } }
      it "assigns @malts[:specialty] a hash ordered by malt amount" do
        maltster.order_specialty_malts
        expect(@recipe.malts[:specialty]).to eq({ malt_1 => 2.25, malt => 2, malt_2 => 0.5 })
      end
    end
  end

  describe "malt_amount" do
    context "base malt" do
      it "picks a number 5..14" do
        expect(maltster.malt_amount(malt)).to be_between(5, 14).inclusive
      end
    end
    context "specialty grain" do
      it "picks a number 0.125..4" do
        expect(maltster.malt_amount(malt_3)).to be_between(0.125, 4.0).inclusive
      end
    end
  end
end