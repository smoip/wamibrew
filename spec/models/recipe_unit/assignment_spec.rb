# require 'spec_helper'

describe "variable assignment" do
  before do
    @recipe = Recipe.new
    @recipe.save!
  end
  after { @recipe.destroy! }
  let(:malt) { FactoryGirl.build(:malt) }
  let(:malt_1) { FactoryGirl.build(:malt, name: 'test malt_1') }
  let(:malt_2) { FactoryGirl.build(:malt, name: 'test malt_2') }
  let(:hop) { FactoryGirl.build(:hop) }
  let(:yeast) { FactoryGirl.build(:yeast) }

  describe "malt assignment" do

    # describe "order_specialty_malts" do
    #   after { @recipe.malts[:specialty]= {} }
    #   context "no specialty malts" do
    #     it "assigns @malts[:specialty] an empty hash" do
    #       expect(@recipe.malts[:specialty]).to eq({})
    #     end
    #   end
    #   context "specialty malts present" do
    #     before { @recipe.malts[:specialty]= { malt => 2, malt_1 => 2.25, malt_2 => 0.5 } }
    #     it "assigns @malts[:specialty] a hash ordered by malt amount" do
    #       expect(@recipe.malts[:specialty]).to eq({ malt_1 => 2.25, malt => 2, malt_2 => 0.5 })
    #     end
    #   end
    # end

    # describe "store_malt" do
    #   before { allow( @recipe ).to receive( :malt_amount ).and_return( 2.11 ) }
    #   context "malt is not already present in recipe" do
    #     before { @recipe.store_malt( :base, malt ) }
    #     after { @recipe.malts = { :base => {}, :specialty => {} } }
    #     it "creates a new entry for this malt in the malt hash according to key" do
    #       expect( @recipe.malts[:base] ).to eq( { malt => 2.11 } )
    #     end
    #     it "does not add this malt to the wrong key in the malt hash" do
    #       expect( @recipe.malts[:specialty] ).not_to eq( { malt => 2.11 } )
    #     end
    #   end

    #   context "malt is already present in recipe" do
    #     before do
    #       @recipe.malts[:specialty] = { malt => 1 }
    #       @recipe.store_malt( :specialty, malt )
    #     end
    #     after { @recipe.malts = { :base => {}, :specialty => {} } }
    #     it "adds this malt to the existing entry in the malt hash" do
    #       expect( @recipe.malts[:specialty] ).to eq( { malt => 3.11 } )
    #     end

    #     it "does not create a new entry for this malt in the malt hash" do
    #       expect( @recipe.malts[:base] ).not_to eq( { malt => 2.11 } )
    #     end
    #   end
    # end



    # describe "malt_type_to_key" do
    #   context "type = true" do
    #     it "should return :base" do
    #       expect( @recipe.malt_type_to_key( true ) ).to eq( :base )
    #     end
    #   end

    #   context "type = false" do
    #     it "should return :specialty" do
    #       expect( @recipe.malt_type_to_key( false ) ).to eq( :specialty )
    #     end
    #   end
    # end

    # describe "num_specialty_malts" do
    #   it "should pick 0..1" do
    #     allow( @recipe ).to receive( :rand ).and_return( 0 )
    #     expect( @recipe.num_specialty_malts ).to be_between(0, 1).inclusive
    #   end

    #   it "should pick 1..2" do
    #     allow( @recipe ).to receive( :rand ).and_return( 1 )
    #     expect( @recipe.num_specialty_malts ).to be_between(1, 2).inclusive
    #   end

    #   it "should pick 2..4" do
    #     allow( @recipe ).to receive( :rand ).and_return( 2 )
    #     expect( @recipe.num_specialty_malts ).to be_between(1, 3).inclusive
    #   end

    #   it "should pick 4..5" do
    #     allow( @recipe ).to receive( :rand ).and_return( 3 )
    #     expect( @recipe.num_specialty_malts ).to be_between(2, 4).inclusive
    #   end

    #   it "should pick 4..5" do
    #     allow( @recipe ).to receive( :rand ).and_return( 4 )
    #     expect( @recipe.num_specialty_malts ).to be_between(3, 5).inclusive
    #   end
    # end

    describe "malts_to_array" do
      after { @recipe.malts = nil }
      context "with specialty malts" do
        it "returns base malt and one specialty malt" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0 } }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ], [ malt_1, 1.0 ] ] )
        end

        it "returns base malt and multiple specialty malts" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => { malt_1 => 1.0, malt_2 => 0.25 } }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ], [ malt_1, 1.0 ], [ malt_2, 0.25 ] ] )
        end
      end

      context "without specialty malts" do
        it "returns base malt only" do
          @recipe.malts = { :base => { malt => 10.0 }, :specialty => {} }
          expect( @recipe.malts_to_array ).to eq( [ [ malt, 10.0 ] ] )
        end
      end
    end

  end

  describe "hops assignment" do

    describe "store_hop" do
      before { allow( @recipe ).to receive( :hop_amount ).and_return( 2.0 ) }
      context "type == bittering" do
        it "stores a bittering hop" do
          allow( @recipe ).to receive( :hop_time ).and_return( 60 )
          @recipe.hops = { :bittering => {}, :aroma => [] }
          @recipe.store_hop( :bittering, hop, true )
          expect( @recipe.hops[:bittering] ).to eq( { hop => [ 2.0, 60 ] } )
        end
      end
      context "type == aroma" do
        before { allow( @recipe ).to receive( :hop_time ).and_return( 10 ) }
        it "stores the first aroma hop" do
          @recipe.hops = { :bittering => {}, :aroma => [] }
          @recipe.store_hop( :aroma, hop, false )
          expect( @recipe.hops[:aroma] ).to eq( [ { hop => [ 2.0, 10 ] } ] )
        end
        it "stores subsequent aroma hops" do
          @recipe.hops = { :bittering => {}, :aroma => [ { hop => [ 1.5, 5 ] } ] }
          @recipe.store_hop( :aroma, hop, false )
          expect( @recipe.hops[:aroma] ).to eq( [ { hop => [ 1.5, 5 ] }, { hop => [ 2.0, 10 ] } ] )
        end
      end
    end

    describe "hop_type_to_key" do
      it "returns :bittering" do
        expect( @recipe.hop_type_to_key(true) ).to eq( :bittering )
      end
      it "returns :aroma" do
        expect( @recipe.hop_type_to_key(false) ).to eq( :aroma )
      end
    end

    describe "similar_hop" do
      context "bittering hop" do
        it "returns a hop object" do
          expect( @recipe.similar_hop(true) ).to be_kind_of( Hop )
        end
      end
      context "aroma hop" do
        it "returns a hop object" do
          allow( @recipe ).to receive( :rand ).and_return( 2 )
          expect( @recipe.similar_hop(false) ).to be_kind_of( Hop )
        end
        it "returns hop object of the same type as previous assignment" do
          allow( @recipe ).to receive( :rand ).and_return( 1 )
          allow( @recipe ).to receive( :hop_names_to_array ).and_return( [ 'cascade' ] )
          expect( @recipe.similar_hop(false) ).to be_kind_of( Hop )
          expect( (@recipe.similar_hop(false)).name ).to eq( 'cascade' )
        end
        it "does" do
          allow( @recipe ).to receive( :rand ).and_return( 1 )
          allow( @recipe ).to receive( :hop_names_to_array ).and_return( [] )
          expect( @recipe.similar_hop(false) ).to be_kind_of( Hop )
        end
      end
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
      before { allow( @recipe ).to receive( :re_assign_hops ).and_return( 'assigning hops...' ) }
      context "abv <= 4.5 && ibu > 60" do
        before do
          @recipe.abv = 3.0
          @recipe.ibu = 72
        end
        it "should reassign hops" do
          expect( @recipe.ibu_gravity_check ).to eq( 'assigning hops...' )
        end
      end
      context "abv <=  6.0 && ibu > 90" do
        before do
          @recipe.abv = 5.2
          @recipe.ibu = 99
        end
        it "should reassign hops" do
          expect( @recipe.ibu_gravity_check ).to eq( 'assigning hops...' )
        end
      end
      context "abv > 4.5 && ibu > 60" do
        before do
          @recipe.abv = 4.6
          @recipe.ibu = 80
        end
        it "should not reassign hops" do
          expect( @recipe.ibu_gravity_check ).not_to eq( 'assigning hops...' )
        end
      end
      context "abv <= 4.5 && ibu < 60" do
        before do
          @recipe.abv = 3.1
          @recipe.ibu = 55
        end
        it "should not reassign hops" do
          expect( @recipe.ibu_gravity_check ).not_to eq( 'assigning hops...' )
        end
      end
    end

    describe "re_assign_hops" do
      before do
        allow( @recipe ).to receive( :ibu_gravity_check ).and_return( 'gravity check' )
        allow( @recipe ).to receive( :extreme_ibu_check ).and_return( 'gravity check' )
        allow( @recipe ).to receive( :assign_hops ).and_return( nil )
        allow( @recipe ).to receive( :calc_bitterness ).and_return( nil )
      end
      after { @recipe.stack_token = nil }
      context "stack_token > 15" do
        before { @recipe.stack_token = 16 }
        it "should not run ibu/gravity checks" do
          expect( @recipe.re_assign_hops ).not_to eq( 'gravity check' )
        end
      end

      context "stack_token <= 15" do
        before { @recipe.stack_token = 14 }
        it "should run ibu/gravity comparisons" do
          expect( @recipe.re_assign_hops ).to eq( 'gravity check' )
        end
      end
    end

    describe "hops_to_array" do
      after { @recipe.hops = nil }
      context "with aroma hops" do
        it "returns bittering hops and one aroma hops" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] } ] }
          expect( @recipe.hops_to_array ).to eq( [ [ hop, [ 1.5, 60 ] ], [ hop, [ 1.0, 15 ] ] ] )
        end

        it "returns bittering hops and multiple aroma hops" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] }, { hop => [ 2.25, 5 ] } ] }
          expect( @recipe.hops_to_array ).to eq( [ [ hop, [ 1.5, 60 ] ], [ hop, [ 1.0, 15 ] ], [ hop, [ 2.25, 5 ] ] ] )
        end
      end

      context "without aroma hops" do
        it "returns bittering hops only" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :specialty => nil }
          expect( @recipe.hops_to_array ).to eq( [ [ hop, [ 1.5, 60 ] ] ] )
        end
      end
    end

    describe "hop_names_to_array" do
      after { @recipe.hops = nil }
      context "has aroma hops" do
        it "returns bittering and aroma hops names in an array" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :aroma => [ { hop => [ 1.0, 15 ] }, { hop => [ 2.25, 5 ] } ] }
          expect( @recipe.hop_names_to_array ).to eq( [ 'cascade test', 'cascade test', 'cascade test' ] )
        end
      end
      context "does not have aroma hops" do
        it "returns only bittering hops names in an array" do
          @recipe.hops = { :bittering => { hop => [ 1.5, 60 ] }, :specialty => nil }
          expect( @recipe.hop_names_to_array ).to eq( [ 'cascade test' ] )
        end
      end
    end

    describe "num_aroma_hops" do
      it "should pick 0..1" do
        allow( @recipe ).to receive( :rand ).and_return( 0 )
        expect( @recipe.num_aroma_hops ).to be_between(0, 1).inclusive
      end

      it "should pick 0..2" do
        allow( @recipe ).to receive( :rand ).and_return( 1 )
        expect( @recipe.num_aroma_hops ).to be_between(0, 2).inclusive
      end

      it "should pick 2..4" do
        allow( @recipe ).to receive( :rand ).and_return( 2 )
        expect( @recipe.num_aroma_hops ).to be_between(1, 3).inclusive
      end

      it "should pick 4..5" do
        allow( @recipe ).to receive( :rand ).and_return( 3 )
        expect( @recipe.num_aroma_hops ).to be_between(2, 4).inclusive
      end

      it "should pick 4..5" do
        allow( @recipe ).to receive( :rand ).and_return( 4 )
        expect( @recipe.num_aroma_hops ).to be_between(3, 5).inclusive
      end

      it "should pick 4..5" do
        allow( @recipe ).to receive( :rand ).and_return( 5 )
        expect( @recipe.num_aroma_hops ).to be_between(4, 6).inclusive
      end
    end
  end

  describe "yeast assignment" do

    describe "choose_yeast" do
      it "should choose a yeast" do
        expect( @recipe.choose_yeast ).to be_kind_of( Yeast )
      end
    end

    describe "associate_yeast" do
      let(:two_row) { Malt.find_by_name( "2-row" ) }
      let(:vienna) { Malt.find_by_name( "vienna" ) }
      context "base malt has associated yeast" do
        before { @recipe.malts = { :base => { two_row => 10.0 }, :specialty => {} } }
        it "chooses an associated yeast by family" do
          expect( @recipe.associate_yeast.family ).to eq( 'ale' )
        end
      end
      context "base malt does not have associated yeast" do
        before { @recipe.malts = { :base => { vienna => 10.0 }, :specialty => {} } }
        it "chooses any yeast" do
          expect( @recipe.associate_yeast ).to be_kind_of( Yeast )
        end
      end
    end

    describe "assign_yeast" do
      it "chooses a yeast" do
        @recipe.yeast = nil
        allow( @recipe ).to receive( :associate_yeast ).and_return( yeast )
        allow( @recipe ).to receive( :choose_yeast ).and_return( yeast )
        @recipe.assign_yeast
        expect( @recipe.yeast ).to eq( yeast )
      end
    end
  end

end