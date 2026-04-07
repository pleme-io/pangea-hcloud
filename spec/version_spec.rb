# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PangeaHcloud do
  describe 'VERSION' do
    it 'is defined' do
      expect(PangeaHcloud::VERSION).not_to be_nil
    end

    it 'follows semantic versioning format' do
      expect(PangeaHcloud::VERSION).to match(/\A\d+\.\d+\.\d+/)
    end

    it 'is frozen' do
      expect(PangeaHcloud::VERSION).to be_frozen
    end
  end
end
