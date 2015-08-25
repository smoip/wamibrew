class AssignHops

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def choose_hop(hop_type)
    hop = similar_hop(hop_type)
    type_key = hop_type_to_key(hop_type)
    store_hop(type_key, hop, hop_type)
  end

  def store_hop(type_key, hop, hop_type)
    if hop_type
      @recipe.hops[type_key][hop]= [hop_amount, hop_time(hop_type)]
    else
      @recipe.hops[type_key] << { hop => [hop_amount, hop_time(hop_type)] }
    end
  end

  def similar_hop(hop_type)
    unless hop_type
      if rand(3) == 1
        unless (@recipe.hop_names_to_array == [])
          hop = Hop.find_by_name(@recipe.hop_names_to_array.last)
          unless hop.nil?
            return hop
          end
        end
      end
    end
    hop = Hop.find_by(id: rand(Hop.count) + 1)
    hop
  end

  def hop_type_to_key(hop_type)
    hop_type ? key = :bittering : key = :aroma
    key
  end

  def num_aroma_hops
    complexity = rand(6)
    [ [ 0, 1 ], [ 0, 1, 2 ], [ 1, 2, 2, 3 ], [ 2, 3, 3, 4 ], [ 3, 4, 5 ], [ 4, 5, 6 ] ][ complexity ].shuffle.first
  end

  def hop_amount
    (rand(12) + 1) / 4.0
  end

  def hop_time(hop_type)
    if hop_type
      if rand(3) == 0
        60
        # force to 60 1/3 of attempts
      else
        t = round_to_fives(rand(25) + 41)
        (t > 60) ? 60 : t
        # pick a number between 60 and 40 rounded to 5
      end
    else
      # pick a number between 30 and 0 rounded to 5
      round_to_fives(rand(35))
    end
  end

private

  def round_to_fives(number)
    (number / 5).round * 5
  end

end