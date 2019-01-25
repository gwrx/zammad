FactoryBot.define do
  factory :'ticket/state', aliases: %i[ticket_state] do
    name do
      # The following line ensures that the name generated by Faker
      # does not conflict with any existing names in the DB.
      # There's a special syntax for this
      # (Faker::Verb.unique.exclude(:past_participle, [], Ticket::State.pluck(:name)),
      # but it's not available yet in the current release of Faker (1.9.1).
      Faker::Verb.unique
                 .instance_variable_get(:@previous_results)
                 .dig([:past_participle, []])
                 .merge(Ticket::State.pluck(:name))

      Faker::Verb.unique.past_participle
    end

    association :state_type, factory: :'ticket/state_type'
    updated_by_id { 1 }
    created_by_id { 1 }
  end
end