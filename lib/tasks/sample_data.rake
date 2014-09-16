namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_malts
    make_hops
    make_yeasts
    make_styles
  end
end

def make_malts
  Malt.create!(name: "2-row",
               potential: 1.037,
               malt_yield: 0.8,
               srm: 1.8,
               base_malt?: true)
  Malt.create!(name: "caramel 60",
               potential: 1.034,
               malt_yield: 0.73,
               srm: 60,
               base_malt?: false)
  Malt.create!(name: "chocolate",
               potential: 1.034,
               malt_yield: 0.75,
               srm: 350,
               base_malt?: false)
  Malt.create!(name: "pilsen",
               potential: 1.037,
               malt_yield: 0.8,
               srm: 1.0,
               base_malt?: true)
end

def make_hops
  Hop.create!(name: "cascade",
              alpha: 5.5)
  Hop.create!(name: "centennial",
              alpha: 10.0)
  Hop.create!(name: "hallertau",
              alpha: 4.8)
end

def make_yeasts
  Yeast.create!(name: "WY1056",
                attenuation: 75,
                family: "ale")
  Yeast.create!(name: "WLP090",
                attenuation: 80,
                family: "ale")
  Yeast.create!(name: "WY2007",
                attenuation: 73,
                family: "lager")
end

def make_styles
  Style.create!(name: "IPA",
                yeast_family: "ale",
                required_malts: nil,
                required_hops: nil,
                common_malts: ["2-row"],
                common_hops: ["cascade"],
                aroma_required?: true,
                abv_upper: 7.5,
                abv_lower: 5.5,
                ibu_upper: 70,
                ibu_lower: 40,
                srm_upper: 15,
                srm_lower: 6)
  Style.create!(name: "Stout",
                yeast_family: "ale",
                required_malts: nil,
                required_hops: nil,
                common_malts: ["chocolate"],
                common_hops: nil,
                aroma_required?: false,
                abv_upper: 7,
                abv_lower: 5,
                ibu_upper: 75,
                ibu_lower: 35,
                srm_upper: 40,
                srm_lower: 30)
  Style.create!(name: "Pilsner",
                yeast_family: "lager",
                required_malts: ["pilsen"],
                required_hops: nil,
                common_malts: nil,
                common_hops: ["hallertau"],
                aroma_required?: false,
                abv_upper: 5.2,
                abv_lower: 4.4,
                ibu_upper: 45,
                ibu_lower: 25,
                srm_upper: 2,
                srm_lower: 5)
end