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
end

def make_hops
  Hop.create!(name: "cascade",
              alpha: 5.5)
  Hop.create!(name: "centennial",
              alpha: 10.0)
end

def make_yeasts
  Yeast.create!(name: "WY1056",
                attenuation: 75,
                family: "ale")
  Yeast.create!(name: "WLP090",
                attenuation: 80,
                family: "ale")
end

def make_styles
  Style.create!(name: "IPA",
                yeast_family: "ale",
                abv: [5.5, 7.5],
                ibu: [40, 70],
                srm: [6, 15],
                required_malts: nil,
                required_hops: nil,
                common_malts: ["2-row"],
                common_hops: ["cascade"],
                aroma_required?: true)
end