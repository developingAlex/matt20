require 'spec_helper'

describe RouteFinder do
  subject { described_class.new(nil) }
  describe 'get_readable_route' do
    it 'returns a string of all the string elements of the array
    joined together by ~> symbols' do
      expect(subject.send :get_readable_route, ['test','this']).to eq 'test ~> this'
    end
  end
end