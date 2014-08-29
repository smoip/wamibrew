namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_malts
    make_hops
    make_yeasts
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
end

def make_hops
  Hop.create!(name: "cascade",
              alpha: 5.5)
end

def make_yeasts
  Yeast.create!(name: "WY1056",
                attenuation: 75,
                family: "ale")
end