FactoryGirl.define do

  factory :malt do
    name       "2-row"
    potential  "1.037"
    malt_yield "0.8"
    srm        "1.8"
    base_malt? "true"
  end

  factory :hop do
    name  "cascade"
    alpha "5.5"
  end

  factory :yeast do
    name        "WY1056"
    attenuation "75"
    family      "ale"
  end
end