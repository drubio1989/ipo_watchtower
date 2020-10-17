require 'rails_helper'

require "rails_helper"

RSpec.describe "Companies", type: :routing do

  describe 'companies friendly_id route' do
    let(:company) { create(:company) }

    it 'is a valid route' do
      expect(get: "/api/v1/ipo/companies/#{company.slug}").to be_routable
    end
  end
end
