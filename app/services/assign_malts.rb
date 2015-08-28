class AssignMalts

  # attr_accessor :malts

  def initialize(malts)
    @malts = malts
  end

  def choose_malt(malt_type)
    malt = Malt.where(base_malt?: malt_type).shuffle.first
    type_key = malt_type_to_key(malt_type)
    [ type_key, malt, malt_amount(malt) ]
  end

  def num_specialty_malts
    complexity = rand(5)
    [ [ 0, 1 ], [ 1, 2 ], [ 1, 2, 2, 3 ], [ 2, 3, 4 ], [ 3, 4, 5 ] ][ complexity ].shuffle.first
  end

  def malt_type_to_key(malt_type)
    malt_type ? key = :base : key = :specialty
    key
  end

  def malt_amount(malt)
    if malt.base_malt?
      rand(10) + 5.0
    else
      (rand(16) + 1) / 8.0
    end
  end

  def order_specialty_malts(malts)
    specialty_ary = (malts[:specialty].sort_by { |malt, amt| amt }).reverse
    Hash[*specialty_ary.flatten]
  end

end