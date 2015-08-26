class HopsArrays

  attr_accessor :recipe

  def initialize(recipe)
    @recipe = recipe
  end

  def hops_to_array
    hop_ary = []
    unless @recipe.hops[:aroma].nil?
      @recipe.hops[:aroma].each do |aroma_hash|
        hop_ary << aroma_hash.to_a
      end
      hop_ary = hop_ary.flatten(1)
    end
    hop_ary.unshift(@recipe.hops[:bittering].to_a[0])
  end

  def hop_names_to_array
    hop_ary = []
    unless @recipe.hops[:aroma].nil?
      @recipe.hops[:aroma].each do |aroma_hash|
        aroma_hash.each_key do |aroma|
          hop_ary << aroma.name
        end
      end
    end
    bitter = []
    @recipe.hops[:bittering].each_key do |bittering|
      bitter << bittering.name
    end
    hop_ary.unshift(bitter)
    hop_ary.flatten
  end
end