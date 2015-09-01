require 'service_objects_helper'

describe AddColor do
  include_context "shared service variables"
  let(:color) { AddColor.new(@recipe.style, @recipe.name, @recipe.srm) }

  describe "add_color_to_name" do
    before do
      allow(NameHelpers).to receive(:check_smash_name).with(color.name).and_return(false)
      allow(color).to receive(:choose_color_adjective).and_return('adding adjective...')
    end
    context "with assigned style" do
      before { color.style = style }
      it "should not attempt to pick an adjective" do
        expect(color.add_color).not_to eq('adding adjective...')
      end
    end

    context "without assigned style" do
      before do
        color.style = nil
        allow(color).to receive(:rand).and_return(1)
        allow(color).to receive(:color_lookup).and_return(nil)
        allow(color).to receive(:name).and_return(nil)
      end
      it "should attempt to pick an adjective" do
        expect(color.add_color).to eq('adding adjective...')
      end
    end
  end

  describe "color_lookup" do
    after { color.srm = nil }
    context "srm < 3" do
      before { color.srm = 1.2 }
      it "should be \'yellow\'" do
        expect(color.color_lookup).to eq(:yellow)
      end
    end

    context "srm = 3" do
      before { color.srm = 3.0 }
      it "should be \'yellow\'" do
        expect(color.color_lookup).to eq(:yellow)
      end
    end

    context "srm 4-7" do
      before { color.srm = 5.4 }
      it "should be \'gold\'" do
        expect(color.color_lookup).to eq(:gold)
      end
    end

    context "srm 8-11" do
      before { color.srm = 9.8 }
      it "should be \'amber\'" do
        expect(color.color_lookup).to eq(:amber)
      end
    end

    context "srm 12-14" do
      before { color.srm = 12.1 }
      it "should be \'red\'" do
        expect(color.color_lookup).to eq(:red)
      end
    end

    context "srm 15-20" do
      before { color.srm = 18.6 }
      it "should be \'brown\'" do
        expect(color.color_lookup).to eq(:brown)
      end
    end

    context "srm 21-25" do
      before { color.srm = 23.0 }
      it "should be \'dark_brown\'" do
        expect(color.color_lookup).to eq(:dark_brown)
      end
    end

    context "srm 26-35" do
      before { color.srm = 34.2 }
      it "should be \'black\'" do
        expect(color.color_lookup).to eq(:black)
      end
    end

    context "srm 36+" do
      before { color.srm = 48.3 }
      it "should be \'dark_black\'" do
        expect(color.color_lookup).to eq(:dark_black)
      end
    end
  end

  describe "choose_color_adjective" do
    let(:options) { [] }

    context "color yellow" do
      before  { [ "Very Pale", "Blonde", "Light Gold" ].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a yellow synonym" do
        expect([ [ color.choose_color_adjective(:yellow) ] & options ][0]).to be_truthy
      end
    end

    context "color gold" do
      before  { [ "Gold", "Golden", "Blonde" ].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a gold synonym" do
        expect([ [ color.choose_color_adjective(:gold) ] & options ][0]).to be_truthy
      end
    end

    context "color amber" do
      before  { [ "Amber", "Copper" ].each { |adj| options << adj } }
      after { options = [] }
      it "should choose an amber synonym" do
        expect([ [ color.choose_color_adjective(:amber) ] & options ][0]).to be_truthy
      end
    end

    context "color red" do
      before  { [ "Amber", "Red" ].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a red synonym" do
        expect([ [ color.choose_color_adjective(:red) ] & options ][0]).to be_truthy
      end
    end

    context "color brown" do
      before  { [ "Chestnut", "Brown"].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a brown synonym" do
        expect([ color.choose_color_adjective(:brown) ] & options).to be_truthy
      end
    end

    context "color dark brown" do
      before  { [ "Dark Brown", "Brown"].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a dark brown synonym" do
        expect([ [ color.choose_color_adjective(:dark_brown) ] & options ][0]).to be_truthy
      end
    end

    context "color black" do
      before  { [ "Black", "Dark Brown", "Dark"].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a black synonym" do
        expect([ [ color.choose_color_adjective(:black) ] & options ][0]).to be_truthy
      end
    end

    context "color dark black" do
      before  { [ "Very Dark", "Black", "Jet Black"].each { |adj| options << adj } }
      after { options = [] }
      it "should choose a dark black synonym" do
        expect([ [ color.choose_color_adjective(:dark_black) ] & options ][0]).to be_truthy
      end
    end

  end

end
