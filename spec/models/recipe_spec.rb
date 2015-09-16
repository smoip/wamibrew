require 'rails_helper'

describe Recipe do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after { @recipe.destroy! }

  subject  { @recipe }

  it { should respond_to(:name) }
  it { should respond_to(:style) }
  it { should respond_to(:abv) }
  it { should respond_to(:ibu) }
  it { should respond_to(:srm) }
  it { should respond_to(:malts) }
  it { should respond_to(:hops) }
  it { should respond_to(:yeast) }
  it { should respond_to(:og) }
  it { should respond_to(:stack_token)}

  it { should be_valid }

  describe "ingredient methods" do

    describe "name" do
      let(:style) { FactoryGirl.build(:style) }
      describe "generate_name" do
        before do
          allow(@recipe).to receive(:check_smash).and_return(nil)
          allow(@recipe).to receive(:add_yeast_family).and_return(nil)
          allow(@recipe).to receive(:add_ingredient_to_name).and_return(nil)
          allow(@recipe).to receive(:add_color_to_name).and_return(nil)
          allow(@recipe).to receive(:nationality_check).and_return(nil)
          allow(@recipe).to receive(:add_strength_to_name).and_return(nil)
          allow(@recipe).to receive(:add_article).and_return(nil)
        end
        it "should use the default name" do
          @recipe.generate_name
          expect(@recipe.name).to eq('Beer')
        end
        it "should use the style name" do
          @recipe.style = style
          @recipe.generate_name
          expect(@recipe.name).to eq(style.name)
        end
      end

      describe "name integration" do
        before { @recipe.choose_attributes }
        it "generates a name" do
          expect(@recipe.name).not_to eq('Beer')
        end
      end

      describe "name additions" do

        describe "by hoppiness" do
          pending
        end

        describe "add_article" do
          context "with name \'ale\'" do
            before { @recipe.name = 'Ale' }
            it "should add \'An\'" do
              @recipe.add_article
              expect(@recipe.name).to eq('An Ale')
            end
          end

          context "with \'Amber\'" do
            before { @recipe.name = "Amber" }
            it "should add \'An\'" do
              @recipe.add_article
              expect(@recipe.name).to eq("An Amber")
            end
          end

          context "with other vowel-start name" do
            before { @recipe.name  = "Imperial Stout" }
            it "should add \'An\'" do
              @recipe.add_article
              expect(@recipe.name).to eq("An Imperial Stout")
            end
          end

          context "with vowel-start and extra whitespace" do
            before { @recipe.name = " Ale" }
            it "should add \'An\'" do
              @recipe.add_article
              expect(@recipe.name).to eq("An Ale")
            end
          end

          context "with consonant-start" do
            before { @recipe.name = "Session IPA" }
            it "should add \'A\'" do
              @recipe.add_article
              expect(@recipe.name).to eq("A Session IPA")
            end
          end
        end

      end
    end

    describe "malt" do
      let(:malt) { FactoryGirl.build(:malt) }
      subject { @recipe.malts }

      it { should be_present }
      it { should have_key :base }
      it { should have_key :specialty }

      describe "assign malts" do
        it "assigns some malts" do
          @recipe.malts = { :base => {}, :specialty => {} }
          @recipe.assign_malts
          expect(@recipe.malts[:base]).not_to eq({})
        end
      end

      describe "store_malt" do
        context "malt is not already present in recipe" do
          before do
            @recipe.malts = { :base => {}, :specialty => {} }
            @recipe.store_malt([:base, malt, 2.11])
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
            @recipe.store_malt([:specialty, malt, 3.0])
          end
          it "adds this malt to the existing entry in the malt hash" do
            expect(@recipe.malts[:specialty]).to eq({ malt => 4.0 })
          end
          it "does not create a new entry for this malt in the malt hash" do
            expect(@recipe.malts[:base]).not_to eq({ malt => 3.0 })
          end
        end
      end
    end

    describe "hops" do
      let(:hop) { FactoryGirl.build(:hop) }
      subject { @recipe.hops }

      it { should be_present }
      it { should have_key :bittering }
      it { should have_key :aroma }

      describe "assign hops" do
        it "assigns some hops" do
          @recipe.hops = { :bittering => {}, :aroma => [] }
          @recipe.assign_hops
          expect(@recipe.hops[:bittering]).not_to eq({})
        end
      end

      describe "store_hop" do
        context "type == bittering" do
          before do
            @recipe.hops = { :bittering => {}, :aroma => [] }
            @recipe.store_hop([:bittering, hop, 2.0, 60])
          end
          it "stores a bittering hop" do
            expect(@recipe.hops[:bittering]).to eq({ hop => [ 2.0, 60 ] })
          end
        end
        context "type == aroma" do
          it "stores the first aroma hop" do
            @recipe.hops = { :bittering => {}, :aroma => [] }
            @recipe.store_hop([:aroma, hop, 2.0, 10])
            expect(@recipe.hops[:aroma]).to eq([ { hop => [ 2.0, 10 ] } ])
          end
          it "stores subsequent aroma hops" do
            @recipe.hops = { :bittering => {}, :aroma => [ { hop => [ 1.5, 5 ] } ] }
            @recipe.store_hop([:aroma, hop, 2.0, 10])
            expect(@recipe.hops[:aroma]).to eq([ { hop => [ 1.5, 5 ] }, { hop => [ 2.0, 10 ] } ])
          end
        end
      end
    end

    describe "yeast" do
      describe "assign yeast" do
        it "assign a yeast" do
          @recipe.yeast = nil
          @recipe.assign_yeast
          expect(@recipe.yeast).to be_present
        end
      end
    end
  end


  describe "choose_attributes" do
    let(:another_recipe) { Recipe.new }
    before { another_recipe.choose_attributes }

    it "should populate instance variables with values" do
      expect(another_recipe.malts).to be_present
      expect(another_recipe.malts[:base].to_a.flatten[0]).to be_kind_of(Malt)
      expect(another_recipe.hops).to be_present
      expect(another_recipe.hops[:bittering].to_a.flatten[0]).to be_kind_of(Hop)
      expect(another_recipe.yeast).to be_present
      expect(another_recipe.og).to be_present
      expect(another_recipe.abv).to be_present
      expect(another_recipe.srm).to be_present
      expect(another_recipe.ibu).to be_present
    end
  end

  describe "style determination" do
    let(:style) { FactoryGirl.build(:style) }
    let(:style_b) { FactoryGirl.build(:style, name: 'another style') }
    let(:style_list) { [ style, style_b ] }

    describe "filter_possible_styles" do
      before do
        allow(@recipe).to receive(:select_by_yeast).and_return(nil)
        allow(@recipe).to receive(:select_by_malt).and_return(nil)
      end
      context "no style by aroma, malt, or yeast" do
        before { allow(@recipe).to receive(:select_by_aroma).and_return([]) }
        it "returns an empty array" do
          expect(@recipe.filter_possible_styles).to eq([])
        end
      end
      context "possible styles by aroma, malt, and yeast" do
        before do
          allow(@recipe).to receive(:select_by_aroma).and_return( style_list )
          allow(@recipe).to receive(:select_by_abv).and_return([ style ])
        end
        context "one of three matches" do
          it "returns an empty array" do
            expect(@recipe.filter_possible_styles).to eq([])
          end
        end
        context "two of three matches" do
          it "returns an empty array" do
            allow(@recipe).to receive(:select_by_ibu).and_return([ style ])
            expect(@recipe.filter_possible_styles).to eq([])
          end
        end
        context "all three matches, one possible style" do
          it "returns a style" do
            allow(@recipe).to receive(:select_by_ibu).and_return([ style ])
            allow(@recipe).to receive(:select_by_srm).and_return([ style ])
            expect(@recipe.filter_possible_styles).to eq([ style ])
          end
        end
        context "all three matches, multiple possible styles" do
          it "returns multiple styles" do
            allow(@recipe).to receive(:select_by_abv).and_return( style_list )
            allow(@recipe).to receive(:select_by_ibu).and_return( style_list )
            allow(@recipe).to receive(:select_by_srm).and_return( style_list )
            expect(@recipe.filter_possible_styles).to eq( style_list )
          end
        end
      end
    end

    describe "assign_style" do
      context "no style matches" do
        before { allow(@recipe).to receive(:filter_possible_styles).and_return([]) }
        it "does not assign a style" do
          @recipe.assign_style
          expect(@recipe.style).to eq(nil)
        end
      end
      context "one possible style" do
        before { allow(@recipe).to receive(:filter_possible_styles).and_return([style]) }
        it "assigns that style" do
          @recipe.assign_style
          expect(@recipe.style).to eq(style)
        end
      end
      context "multiple possible styles" do
        before do
          allow(@recipe).to receive(:filter_possible_styles).and_return(style_list)
          allow(@recipe).to receive(:filter_style_by_ingredients).and_return(style)
        end
        it "assigns a style" do
          @recipe.assign_style
          expect(@recipe.style).to eq(style)
        end
      end
    end
  end
end
