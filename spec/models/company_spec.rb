require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:a) { create(:company, name: 'ACME Inc.') }
  let(:b) { create(:company, name: 'Beta Corp') }
  let(:f) { create(:company, name: 'Financial News LLC.') }

  it { should have_one(:ipo_profile) }
  it { should have_db_column(:slug) }

  describe '.name_starts_with_letter' do
    it 'lists companies that start with a particular letter' do
      expect(described_class.name_starts_with_letter('A')).to eq [a]
      expect(described_class.name_starts_with_letter('B')).to eq [b]
      expect(described_class.name_starts_with_letter('F')).to eq [f]
    end
  end
end
