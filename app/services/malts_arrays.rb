class MaltsArrays

  attr_accessor :malts

  def initialize(malts)
    @malts = malts
  end

  def malts_to_array
    malt_ary = []
    unless @malts[:specialty] == {}
      @malts[:specialty].each do |malt_obj, amt|
        malt_ary << [malt_obj, amt]
      end
    end
    malt_ary.unshift(@malts[:base].to_a[0])
  end

  def malt_names_to_array
    malts_ary = malts_to_array.flatten.keep_if { |x| x.class == Malt }
    malts_ary.collect { |malt| malt.name }
  end
end