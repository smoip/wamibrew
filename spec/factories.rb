FactoryGirl.define do

  factory :recipe do
    name 'Test'
    style nil
    abv 5.0
    ibu 40
    srm 3.5
    malts nil
    hops nil
    yeast nil
    og 1.056
    stack_token 0
  end

  factory :malt do
    name       "2-row test"
    potential  1.037
    malt_yield 0.8
    srm        1.8
    base_malt? true
  end

  factory :hop do
    name  "cascade test"
    alpha 5.5
  end

  factory :yeast do
    name        "WY1056 test"
    attenuation 75
    family      "ale"
  end

  factory :style do
    name            "American IPA"
    yeast_family    "ale"
    required_malts  nil
    required_hops   nil
    common_malts    ["2-row"]
    common_hops     ["cascade", "citra"]
    aroma_required? true
    abv_upper       7.5
    abv_lower       5.5
    ibu_upper       70
    ibu_lower       40
    srm_upper       15
    srm_lower       6
  end
end