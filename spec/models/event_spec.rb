# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :string
#  max_participants :integer
#  active           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

describe Event do

  let(:event) { FactoryGirl.create :event, :with_two_date_ranges }

  it "is created by event factory" do
    expect(event).to be_valid
  end

  it "checks if there are unclassified applications_letters" do
    event = FactoryGirl.create(:event)
    accepted_application_letter = FactoryGirl.create(:application_letter_accepted, :event => event, :user => FactoryGirl.create(:user))
    event.application_letters.push(accepted_application_letter)
    expect(event.applications_classified?).to eq(true)

    pending_application_letter = FactoryGirl.create(:application_letter, :event => event, :user => FactoryGirl.create(:user))
    event.application_letters.push(pending_application_letter)
    expect(event.applications_classified?).to eq(false)
  end

  it "computes the email addresses of the accepted and the rejected applications" do
    event = FactoryGirl.create(:event)
    accepted_application_letter_1 = FactoryGirl.create(:application_letter_accepted, :event => event, :user => FactoryGirl.create(:user))
    accepted_application_letter_2 = FactoryGirl.create(:application_letter_accepted, :event => event, :user => FactoryGirl.create(:user))
    accepted_application_letter_3 = FactoryGirl.create(:application_letter_accepted, :event => event, :user => FactoryGirl.create(:user))
    rejected_application_letter = FactoryGirl.create(:application_letter_rejected, :event => event, :user => FactoryGirl.create(:user))
    event.application_letters.push(accepted_application_letter_1)
    event.application_letters.push(accepted_application_letter_2)
    event.application_letters.push(accepted_application_letter_3)
    event.application_letters.push(rejected_application_letter)
    expect(event.accepted_applications_emails).to eq([accepted_application_letter_1.user.email, accepted_application_letter_2.user.email, accepted_application_letter_3.user.email].join(','))
    expect(event.rejected_applications_emails).to eq([rejected_application_letter.user.email].join(','))
  end

  it "is either a camp or a workshop" do
    expect { FactoryGirl.build(:event, kind: :smth_invalid) }.to raise_error(ArgumentError)

    event = FactoryGirl.build(:event, kind: :camp)
    expect(event).to be_valid

    event = FactoryGirl.build(:event, kind: :workshop)
    expect(event).to be_valid
  end

  it "should have one or more date-ranges" do

    #checking if the event model can handle date_ranges
    expect(event.date_ranges.size).to eq 2
    expect(event.date_ranges.first.start_date).to eq(Date.tomorrow)
    expect(event.date_ranges.first.end_date).to eq(Date.tomorrow.next_day(5))
    expect(event.date_ranges.second.start_date).to eq(Date.tomorrow)
    expect(event.date_ranges.second.end_date).to eq(Date.tomorrow.next_day(10))
    expect(event.date_ranges.second).to eq(event.date_ranges.last)

    #making sure that every event has at least one date range
    event1 = FactoryGirl.build(:event, :without_date_ranges)
    expect(event1).to_not be_valid
  end

  describe "#start_date" do
    it "should return return its minimum over all date ranges" do
      event = FactoryGirl.create :event, :with_multiple_date_ranges
      expect(event.start_date).to eq(Date.today)
    end
  end

  describe "#end_date" do
    it "should return return its maximum over all date ranges" do
      event = FactoryGirl.create :event, :with_multiple_date_ranges
      expect(event.end_date).to eq(Date.today.next_day(16))
    end
  end

  describe "#unreasonably_long" do
    it "should be true if the event is longer than defined" do
      event = FactoryGirl.create :event, :with_unreasonably_long_range
      expect(event.unreasonably_long).to be true
    end
  end

  it "returns the event's participants" do
    event = FactoryGirl.build(:event)
    FactoryGirl.create(:application_letter_rejected, event: event)
    accepted_letter = FactoryGirl.create(:application_letter_accepted, event: event)
    expect(event.participants).to eq [accepted_letter.user]
  end

  it "returns a user's agreement letter for itself" do
    event = FactoryGirl.create(:event)
    user = FactoryGirl.create(:user)
    irrelevant_user = FactoryGirl.create(:user)
    FactoryGirl.create(:agreement_letter, user: irrelevant_user)
    agreement_letter = FactoryGirl.create(:agreement_letter, user: user, event: event)
    expect(event.agreement_letter_for(user)).to eq agreement_letter
  end

  it "returns nil if a user has not uploaded an agreement letter" do
    event = FactoryGirl.create(:event)
    user = FactoryGirl.create(:user)
    irrelevant_user = FactoryGirl.create(:user)
    FactoryGirl.create(:agreement_letter, user: irrelevant_user)
    expect(event.agreement_letter_for(user)).to be_nil
  end

  it "computes the number of free places" do
    event = FactoryGirl.create(:event)
    application_letter = FactoryGirl.create(:application_letter, user: FactoryGirl.create(:user), event: event)
    event.application_letters.push(application_letter)

    expect(event.compute_free_places).to eq(event.max_participants - event.compute_occupied_places)
  end

  it "computes the number of occupied places" do
    event = FactoryGirl.create(:event)
    application_letter = FactoryGirl.create(:application_letter, user: FactoryGirl.create(:user), event: event)
    application_letter_accepted = FactoryGirl.create(:application_letter_accepted, user: FactoryGirl.create(:user), event: event)
    expect(event.compute_occupied_places).to eq(1)
    application_letter_accepted_2 = FactoryGirl.create(:application_letter_accepted, user: FactoryGirl.create(:user), event: event)
    expect(event.compute_occupied_places).to eq(2)
  end
end

