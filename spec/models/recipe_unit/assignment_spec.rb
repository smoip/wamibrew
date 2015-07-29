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
      it "needs a test"
      # unit-testable?
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
        allow( @recipe ).to receive( :one_of_five ).and_return( 0 )
        expect( @recipe.num_specialty_malts ).to be_between(0, 1).inclusive
      end

      it "should pick 2" do
        allow( @recipe ).to receive( :one_of_five ).and_return( 1 )
        expect( @recipe.num_specialty_malts ).to be_between(1, 2).inclusive
      end

      it "should pick 2..4" do
        allow( @recipe ).to receive( :one_of_five ).and_return( 2 )
        expect( @recipe.num_specialty_malts ).to be_between(1, 3).inclusive
      end

      it "should pick 4..5" do
        allow( @recipe ).to receive( :one_of_five ).and_return( 3 )
        expect( @recipe.num_specialty_malts ).to be_between(2, 4).inclusive
      end

      it "should pick 4..5" do
        allow( @recipe ).to receive( :one_of_five ).and_return( 4 )
        expect( @recipe.num_specialty_malts ).to be_between(3, 5).inclusive
      end
    end

    describe "assign_malts" do
      # not sure how to unit test - only calls other methods
      # leave for integration only?
      it "needs a unit test?"
    end

    describe "malts_to_array" do
      after { @recipe.malts = nil }
      context "with specialty malts" do
        it "returns base malt and one specialty malt" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt => 1.0 } }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ], [ malt, 1.0 ] ] )
        end

        it "returns base malt and multiple specialty malts" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt => 1.0, malt => 0.25, malt => 0.125 } }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ], [ malt, 1.0 ], [ malt, 0.25 ], [ malt, 0.125 ] ] )
          # not sure why failing - try with different malt ids? (rather than same Factory item)
        end
      end

      context "without specialty malts" do
        it "returns base malt only" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => {} }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ] ] )
        end
      end
    end

    describe "pull_malt_object" do
      it "should return a malt object" do
        expect( @recipe.pull_malt_object( [ malt, 10.0 ] ) ).to eq( malt )
      end
    end

    describe "pull_malt_name" do
      it "should return \'2-row test\'" do
        expect( @recipe.pull_malt_name( [ malt, 10.0 ] ) ).to eq( '2-row test' )
      end
    end

    describe "pull_malt_amt" do
      it "should return 10.0" do
        expect( @recipe.pull_malt_amt( [ malt, 10.0 ] ) ).to eq( 10.0 )
      end
    end

  end

  describe "hops assignment" do

    describe "choose_hop" do
      it "needs a test"
      # unit-testable?
    end

    describe "extreme_ibu_check" do
      after { @recipe.ibu  = nil }

      context "ibus > 120" do
        before { @recipe.ibu = 124 }
        it "attempts to reassign hops" do
          allow( @recipe ).to receive( :re_assign_hops ).and_return( 'success' )
          expect( @recipe.extreme_ibu_check ).to eq( 'success' )
        end
      end

      context "ibus < 120" do
        before { @recipe.ibu = 15 }
        it "shouldn't raise an error" do
          expect { @recipe.extreme_ibu_check }.not_to raise_error
        end
      end
    end

    describe "ibu_gravity_check" do
      context "abv <= 4.5 && ibu > 60" do
        before do
          @recipe.abv = 3.0
          @recipe.ibu = 72
        end
        it "should reassign hops" do

        end
      end
      context "abv <=  6.0 && ibu > 90" do
        before do
          @recipe.abv = 5.2
          @recipe.ibu = 99
        end
        it "should reassign hops" do

        end
      end
      context "abv > 4.5 && ibu > 60" do
        before do
          @recipe.abv = 4.6
          @recipe.ibu = 80
        end
        it "should not reassign hops" do

        end
      end
      context "abv <= 4.5 && ibu < 60" do
        before do
          @recipe.abv = 3.1
          @recipe.ibu = 55
        end
        it "should not reassign hops" do
        end
      end
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