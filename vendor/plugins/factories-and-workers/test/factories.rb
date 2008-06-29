include FactoriesAndWorkers::Factory

factory :monkey, {
  :name    => "George",
  :unique  => "$UNIQ(10)",
  :counter => "$COUNT",
  :number  => lambda{ increment! :foo }
}

factory :pirate, {
  :catchphrase => "Ahhrrrr, Matey!",
  :monkey      => :belongs_to_model,
  :created_on  => lambda{ 1.day.ago }
}

factory :ninja_pirate, {
  :catchphrase => "(silent)"
}, :class => Pirate, :chain => lambda{ valid_pirate_attributes( :monkey => nil ) }
