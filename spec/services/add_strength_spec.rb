require 'service_objects_helper'

describe AddStrength do
  include_context "shared service variables"

  let(:strength) { AddStrength.new(@recipe.style, @recipe.name, @recipe.abv) }

  describe "add_strength" do
    before do
      allow(NameHelpers).to receive(:check_smash_name).with(strength.name).and_return(false)
      allow(strength).to receive(:choose_strength_adjective).and_return('adding adjective...')
    end
    context "with assigned style" do
      before { strength.style = style }
      it "should not attempt to pick an adjective" do
        expect(strength.add_strength).not_to eq('adding adjective...')
      end
    end

    context "without assigned style" do
      before do
        strength.style = nil
        allow(strength).to receive(:rand).and_return(1)
        allow(strength).to receive(:strength_lookup).and_return(nil)
        allow(strength).to receive(:name).and_return(nil)
      end
      it "should attempt to pick an adjective" do
        expect(strength.add_strength).to eq('adding adjective...')
      end
    end
  end

  describe "strength_lookup" do
    after { strength.abv = nil }
    context "abv 0-2" do
      before { strength.abv = 1.8 }
      it "should be \'weak\'" do
        expect(strength.strength_lookup).to eq(:weak)
      end
    end

    context "abv 3-4" do
      before { strength.abv = 3.0 }
      it "should be \'session\'" do
        expect(strength.strength_lookup).to eq(:session)
      end
    end

    context "abv 5-7" do
      before { strength.abv = 7.0 }
      it "should be \'average\'" do
        expect(strength.strength_lookup).to eq(:average)
      end
    end

    context "abv 8-9" do
      before { strength.abv = 8.9 }
      it "should be \'strong\'" do
        expect(strength.strength_lookup).to eq(:strong)
      end
    end

    context "abv 10+" do
      before { strength.abv = 15 }
      it "should be \'very_strong\'" do
        expect(strength.strength_lookup).to eq(:very_strong)
      end
    end

  end

  describe "choose_strength_adjective" do
    let(:options) { [] }
    context "strength weak" do
      before  { [ "Mild", "Low Gravity" ].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a weak synonym" do
        expect([ [ strength.choose_strength_adjective(:weak) ] & options ][0]).to be_truthy
      end
    end

    context "strength session" do
      before  { [ "sessionable", "quaffable" ].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a weak synonym" do
        expect([ [ strength.choose_strength_adjective(:session) ] & options ][0]).to be_truthy
      end
    end

    context "strength average" do
      it "should not choose an adjective" do
        expect(strength.choose_strength_adjective(:average)).to eq('')
      end
    end

    context "strength strong" do
      before  { [ "Strong" ].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a strong synonym" do
        expect([ [ strength.choose_strength_adjective(:strong) ] & options ][0]).to be_truthy
      end
    end
  end
end