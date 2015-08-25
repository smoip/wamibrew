require 'service_objects_helper'

describe AssignHops do
  include_context "shared service variables"

  describe "choose_hop" do
    let(:hopster) { AssignHops.new(@recipe) }
    context "choose a bittering hop" do
      before { hopster.choose_hop(true) }

      it "should assign a hop to hops[:bittering]" do
        expect(@recipe.hops[:bittering].to_a.flatten[0]).to be_kind_of(Hop)
      end
      it "should choose quantities" do
        expect(@recipe.hops[:bittering].to_a.flatten[1]).to be_between(0.5, 3).inclusive
      end
      it "should choose appropriate bittering times" do
        expect(@recipe.hops[:bittering].to_a.flatten[2]).to be_between(40, 60).inclusive
      end
    end
    context "choose an aroma hop" do
      before { hopster.choose_hop(false) }
      it "should assign a hop to hops[:aroma]" do
        expect(@recipe.hops[:aroma][0].to_a.flatten[0]).to be_kind_of(Hop)
      end
      it "should choose appropriate aroma times" do
        expect(@recipe.hops[:aroma][0].to_a.flatten[2]).to be_between(0, 30).inclusive
      end
    end
  end

  describe "store_hop" do
    context "type == bittering" do
      it "stores a bittering hop" do
        @recipe.hops = { :bittering => {}, :aroma => [] }
        hopster = AssignHops.new(@recipe)
        allow(hopster).to receive(:hop_time).and_return(60)
        allow(hopster).to receive(:hop_amount).and_return(2.0)
        hopster.store_hop(:bittering, hop, true)
        expect(@recipe.hops[:bittering]).to eq({ hop => [ 2.0, 60 ] })
      end
    end
    context "type == aroma" do
      it "stores the first aroma hop" do
        @recipe.hops = { :bittering => {}, :aroma => [] }
        hopster = AssignHops.new(@recipe)
        allow(hopster).to receive(:hop_time).and_return(10)
        allow(hopster).to receive(:hop_amount).and_return(2.0)
        hopster.store_hop(:aroma, hop, false)
        expect(@recipe.hops[:aroma]).to eq([ { hop => [ 2.0, 10 ] } ])
      end
      it "stores subsequent aroma hops" do
        @recipe.hops = { :bittering => {}, :aroma => [ { hop => [ 1.5, 5 ] } ] }
        hopster = AssignHops.new(@recipe)
        allow(hopster).to receive(:hop_time).and_return(10)
        allow(hopster).to receive(:hop_amount).and_return(2.0)
        hopster.store_hop(:aroma, hop, false)
        expect(@recipe.hops[:aroma]).to eq([ { hop => [ 1.5, 5 ] }, { hop => [ 2.0, 10 ] } ])
      end
    end
  end

  describe "hop_type_to_key" do
    let(:hopster) { AssignHops.new(@recipe) }
    it "returns :bittering" do
      expect(hopster.hop_type_to_key(true)).to eq(:bittering)
    end
    it "returns :aroma" do
      expect(hopster.hop_type_to_key(false)).to eq(:aroma)
    end
  end

  describe "similar_hop" do
    let(:hopster) { AssignHops.new(@recipe) }
    context "bittering hop" do
      it "returns a hop object" do
        expect(hopster.similar_hop(true)).to be_kind_of(Hop)
      end
    end
    context "aroma hop" do
      it "returns a hop object" do
        allow(hopster).to receive(:rand).and_return(2)
        expect(hopster.similar_hop(false)).to be_kind_of(Hop)
      end
      it "returns hop object of the same type as previous assignment" do
        allow(hopster).to receive(:rand).and_return(1)
        allow(@recipe).to receive(:hop_names_to_array).and_return([ 'cascade' ])
        expect(hopster.similar_hop(false)).to be_kind_of(Hop)
        expect(hopster.similar_hop(false).name).to eq('cascade')
      end
    end
  end

  describe "num_aroma_hops" do
    let(:hopster) { AssignHops.new(@recipe) }
    it "should pick 0..1" do
      allow(hopster).to receive(:rand).and_return(0)
      expect(hopster.num_aroma_hops).to be_between(0, 1).inclusive
    end

    it "should pick 0..2" do
      allow(hopster).to receive(:rand).and_return(1)
      expect(hopster.num_aroma_hops).to be_between(0, 2).inclusive
    end

    it "should pick 2..4" do
      allow(hopster).to receive(:rand).and_return(2)
      expect(hopster.num_aroma_hops).to be_between(1, 3).inclusive
    end

    it "should pick 4..5" do
      allow(hopster).to receive(:rand).and_return(3)
      expect(hopster.num_aroma_hops).to be_between(2, 4).inclusive
    end

    it "should pick 4..5" do
      allow(hopster).to receive(:rand).and_return(4)
      expect(hopster.num_aroma_hops).to be_between(3, 5).inclusive
    end

    it "should pick 4..5" do
      allow(hopster).to receive(:rand).and_return(5)
      expect(hopster.num_aroma_hops).to be_between(4, 6).inclusive
    end
  end

  describe "hop_amount" do
    let(:hopster) { AssignHops.new(@recipe) }
    it "picks a weight between 0.5 and 3" do
      expect(hopster.hop_amount).to be_between(0.5, 3.0).inclusive
    end
  end

  describe "hop_time" do
    let(:hopster) { AssignHops.new(@recipe) }
    it "picks a bittering time between 40 and 60" do
      expect(hopster.hop_time(true)).to be_between(40, 60).inclusive
    end
    it "picks an aroma time between 0 and 30" do
      expect(hopster.hop_time(false)).to be_between(0, 30).inclusive
    end
  end
end