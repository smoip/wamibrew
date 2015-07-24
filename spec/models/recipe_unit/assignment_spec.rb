require 'rails_helper'

describe "variable assignment" do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after { @recipe.destroy! }
  let(:malt) { FactoryGirl.build(:malt) }

  describe "malt assignment" do

    describe "choose_malt" do
    end

    describe "order_specialty_malts" do
    end

    describe "store_malt" do
      before { allow( @recipe ).to receive( :malt_amount ).and_return( 2.11 ) }
      context "malt is not already present in recipe" do
        before { @recipe.store_malt( :base, malt ) }
        after { @recipe.malts = { :base => {}, :specialty => {} } }
        it "creates a new entry for this malt in the malt hash according to key" do
          expect( @recipe.malts[:base] ).to eq( { malt => 2.11 } )
        end
        it "does not add this malt to the wrong key in the malt hash" do
          expect( @recipe.malts[:specialty] ).not_to eq( { malt => 2.11 } )
        end
      end

      context "malt is already present in recipe" do
        before do
          @recipe.malts[:specialty] = { malt => 1 }
          @recipe.store_malt( :specialty, malt )
        end
        after { @recipe.malts = { :base => {}, :specialty => {} } }
        it "adds this malt to the existing entry in the malt hash" do
          expect( @recipe.malts[:specialty] ).to eq( { malt => 3.11 } )
        end

        it "does not create a new entry for this malt in the malt hash" do
          expect( @recipe.malts[:base] ).not_to eq( { malt => 2.11 } )
        end
      end
    end



    describe "malt_type_to_key" do
      context "type = true" do
        it "should return :base" do
          expect( @recipe.malt_type_to_key( true ) ).to eq( :base )
        end
      end

      context "type = false" do
        it "should return :specialty" do
          expect( @recipe.malt_type_to_key( false ) ).to eq( :specialty )
        end
      end
    end

    describe "num_specialty_malts" do
      it "should pick 0..2" do
        allow( @recipe ).to receive( :one_of_four ).and_return( 0 )
        expect( @recipe.num_specialty_malts ).to be_between(0, 2).inclusive
      end

      it "should pick 2" do
        allow( @recipe ).to receive( :one_of_four ).and_return( 1 )
        expect( @recipe.num_specialty_malts ).to eq( 2 )
      end

      it "should pick 2..4" do
        allow( @recipe ).to receive( :one_of_four ).and_return( 2 )
        expect( @recipe.num_specialty_malts ).to be_between(2, 4).inclusive
      end

      it "should pick 4..5" do
        allow( @recipe ).to receive( :one_of_four ).and_return( 3 )
        expect( @recipe.num_specialty_malts ).to be_between(4, 5).inclusive
      end
    end

    describe "assign_malts" do
    end

    describe "malts_to_array" do
    end

    describe "pull_malt_object" do
    end

    describe "pull_malt_name" do
    end

    describe "pull_malt_amt" do
    end

  end

  describe "hops assignment" do

    describe "chose_hop" do
    end

    describe "extreme_ibu_check" do
    end

    describe "ibu_gravity_check" do
    end

    describe "re_assign_hops" do
    end

    describe "assign_hops" do
    end

    describe "hops_to_array" do
    end

    describe "hop_names_to_array" do
    end

    describe "pull_hop_object" do
    end

    describe "pull_hop_name" do
    end

    describe "pull_hop_amt" do
    end

    describe "pull_hop_time" do
    end

    describe "num_aroma_hops" do
    end

    describe "choose_aroma_hops" do
    end

  end

  describe "yeast assignment" do

    describe "choose_yeast" do
    end

    describe "associate_yeast" do
    end

    describe "assign_yeast" do
    end

  end

end