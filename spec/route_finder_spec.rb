require 'spec_helper'

describe RouteFinder do

  before(:each) do
    line1 = Line.new('line1', ['a','b','c','d','e'])
    line2 = Line.new('line2', ['f','g','d','h','ab'])
    line3 = Line.new('line3', ['i','d','j','k','l'])
    line4 = Line.new('line4', ['m','n','o','p'])
    line5 = Line.new('line5', ['q','o','r','s','t'])
    line6 = Line.new('line6', ['u','v','s','w','x'])
    line7 = Line.new('line7', ['y','s','z','aa','ab'])
    # Build array of lines
    lines = [line1, line2,  line3,  line4,  line5,  line6,  line7]

    lm = LineManager.new
    # Get a line manager to analyse the lines to determine which lines are 
      # neighbours and which stations are junctions:
    lm.determine_neighbours_and_junctions(lines)

    @rf = RouteFinder.new(lines)
  end

  describe 'get_route' do
    it 'returns the first route it finds connecting stations on the same line' do
      expect(@rf.get_route('a','d')).to eq('a ~> b ~> c ~> d')
    end
    
    it 'returns the first route it finds connecting stations going backwards 
      on the same line' do
      expect(@rf.get_route('d','a')).to eq('d ~> c ~> b ~> a')
    end

    it 'returns the first route it finds connecting origin station
      to destination station even when theyre on different lines' do
      
      # Make a new route finder for our array of lines and then test it:
      route_that_jumps_multiple_lines = @rf.get_route('w','a')

      expect(route_that_jumps_multiple_lines).to eq('w ~> s ~> change to the line7 line ~> z ~> aa ~> ab ~> change to the line2 line ~> h ~> d ~> change to the line1 line ~> c ~> b ~> a')

    end
    
    it 'returns an error message if the stations entered are invalid' do
      expect(@rf.get_route('aaa','c')).to eq('There is no station called aaa')
    end
  end
end