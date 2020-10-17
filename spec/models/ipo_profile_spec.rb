require 'rails_helper'

RSpec.describe IpoProfile, type: :model do
  it { should belong_to(:company) }
  it { should belong_to(:industry) }
end
