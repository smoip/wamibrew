module HopsHelpers

  def self.pull_hop_object(hop_ary)
    hop_ary[0]
  end

  def self.pull_hop_name(hop_ary)
    hop_ary[0].name
  end

  def self.pull_hop_amt(hop_ary)
    hop_ary[1][0]
  end

  def self.pull_hop_time(hop_ary)
    hop_ary[1][1]
  end

end