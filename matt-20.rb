# Task: code a basic PTV app (like our public transport app, if you aren't
# familiar). 
# Start by dummying up one or at most two lines at first. The final product 
# would take a user input of an origin station, and a destination station, and 
# return a data structure that contains the stops to pass through, and the line
# changes if required. Perhaps restrict the user input so there cannot be an 
# error returned (the only stations they choose are valid - or assume this, but
# say if that's your choice). Start with one train line, represented by an 
# array. If you extend it to two lines, you need to think about how to 
# represent the lines as data, and this might be a complex object. Think 
# through all the options before coding, and even perhaps pen and paper. You 
# will need some way to carry the user data through the method/s, and some 
# way to represent the MTR. You will likely need several small methods, and 
# will likely have to employ a full range of data types, such as hashes and 
# arrays (and possibly arrays of arrays).

# Line represents a train line consisting of stations, neighboring lines and, 
# of course, a name.
class Line

  # (the names of the stations on this line)
  attr_reader :stations # Array of Strings

  # (the names of the stations on this line that are junctions, stations that 
  # people can change train lines at)
  attr_accessor :junction_stations # Array of Strings 

  attr_reader :name # String

  # ( other Line's that happen to dissect this Line )
  attr_accessor :neighbour_lines # Array of Line objects 
  

  def initialize(name, array_of_stations_end_to_end_ordered)
    @stations = array_of_stations_end_to_end_ordered
    @name = name
    @neighbour_lines = [] #to be figured out by a LineManager
    @junction_stations = [] #to be figured out by a LineManager
  end

  def contains_station?(station_being_checked)
    @stations.include?(station_being_checked)
  end

end

# RouteFinder provides functionality to determine the route from an 'origin' 
# station to a 'dest'ination station, it does not guarantee to return the 
# fastest or shortest route, only the first one it finds.
class RouteFinder

  def initialize(lines)
    @lines = lines # an array of all the train network's Line's
    @lines_searched = [] # array to keep track of lines that have already been 
      # searched when determining path from origin to destination.
  end

  # this is the function that external callers should use
  def get_route(origin,dest)
    #ensure that @lines_searched array is reset to empty
    @lines_searched = []
    #then get the route, and interpret it to add in the line hops, and then get
      # it in a readable form.
    get_readable_route(interpret_route(get_route_recurse(origin,dest)))
  end

  #helper method to get an array of lines that a particular station lies on - 
    # will only have one line unless the station is a junction.
  def get_lines_for_station(station)
    lines = []
    @lines.each do |line|
      if line.stations.include?(station)
        lines << line
      end
    end
    lines
  end

  
  private
  
  # This is the recursive function that finds the path from origin to 
  # destination. It takes two stations as arguments, an origin station and a 
  # destination station and then, looking on the origin's line, checks if the
  # destination station is on that line too. If it is it returns the route 
  # from station to station, if it isn't then it calls itself again but with
  # the origin changed to be one of the junction stations on the origin's 
  # line and the process repeats but now from the point of view of the 
  # junction being the origin, it repeats until either the origin becomes a 
  # junction that is on a line that the destination station is also on, or 
  # the destination wasn't found in which case the function returns nil.

  # it keeps a list of lines it has previously checked so that if it 
  # exhausts its lines to search and hasn't yet found the destination station
  # that it doesn't begin going back the way it came, that 'branch' is 
  # abandoned as a deadend by it returning nil. it then handles a return of 
  # nil as an indication that the destination is not in that direction. 
  # Eventually one of the paths will find the destination station and at that
  # point the function will stop calling itself and will start returning 
  # solid results back to earlier versions of itself all the way back to the 
  # intial 'version' of this function which then returns the value to the 
  # original calling function (def get_route)
  def get_route_recurse(origin,dest)      
    #establish what lines the stations belong to.
    origins_lines = get_lines_for_station(origin)
    dests_lines = get_lines_for_station(dest)
    #and check if the stations share a common line?
    #initialise common_line to nil
    common_line = nil
    origins_lines.each do |origin_line|
      dests_lines.each do |dest_line|
        if origin_line == dest_line
          # then we've found a line in common!
          common_line = origin_line
          break #stop looking
        end
      end
      if !common_line.nil? # if we've already found a common line no need to 
          # make more comparisons so stop looking:
        break
      end
    end
    
    # if the stations didn't share a common line, then we begin the 
    # recursive process:
    #   but if they did, then we can simply list the stations between them 
    #   and return the actual route (this will also be what terminates the 
    #   recursive process)

    if common_line.nil?  # (then the stations are not on the same line)

      # so add the origins lines to the list of lines already searched.
      @lines_searched += origins_lines

      # determine neighbouring lines that have not already been searched,
      neighbouring_lines_to_search = []
      # by checking all lines that run through our 'current' origin
      origins_lines.each do |line|
        # and for each one, figuring out which lines are neighbours of it
        line.neighbour_lines.each do |neighbour_line|
          # that have not yet already been searched
          if !neighbour_line.nil?
            if !@lines_searched.include?(neighbour_line)
              #and adding them to our list of neighbouring lines to search
              neighbouring_lines_to_search << neighbour_line
            end
          end
        end
      end
      
      
      if neighbouring_lines_to_search.empty?
        return nil  # then we've reached a point where we haven't found the 
          # destination station in this direction.
      else
        # for all the neighbouring lines that we haven't looked at yet:
        neighbouring_lines_to_search.each do |neighbour_line_to_search|
          # go through all their junction_stations
          neighbour_line_to_search.junction_stations.each do |junction_station|
            # and find a junction that is on this line
            if stations_on_same_line?(origin, junction_station)
              # ensure we are looking at another junction 
              #   if we're already 'on' one:
              unless origin == junction_station
                # calculate the route from our 'current' origin 
                # to the junction station we're considering
                route_from_origin_to_junction = get_route_recurse(origin, junction_station) 
                #also calculate the route from the junction 
                # station we're considering to the destination station:
                route_from_junction_to_dest = get_route_recurse(junction_station, dest)
                #if either of those return nil then it means we 
                # were not considering an appropriate junction station 
                # or we have been looking in the wrong direction to get 
                # to our destination station and have hit a dead-end
                if !route_from_origin_to_junction.nil? && !route_from_junction_to_dest.nil?
                  #then so far, we're on a branch that's either worth 
                  # pursuing further, or we have already found the 
                  # destination station.
                  return route_from_origin_to_junction + route_from_junction_to_dest
                end
              else
                return nil # call back up the stack that this branch 
                  # was not worth pursuing
              end
            end
          end
        end
      end
      
    else   # The stations are on the same line:
      # This block of code is basically the termination clause of our 
      # recursion.
      # It means that the 'current' origin we're looking from can see the 
      # destination station on one of the lines that it's also on:
      origin_index_in_line = common_line.stations.index(origin)
      dest_index_in_line = common_line.stations.index(dest)
      route = nil
      # Ensure the order of the stations reflects 
      # the direction we're travelling:
      if origin_index_in_line < dest_index_in_line
        route = common_line.stations[origin_index_in_line..dest_index_in_line]
      else
        route = common_line.stations[dest_index_in_line..origin_index_in_line]
        route.reverse!
      end
      return route
    end
  end

    # function to test if two stations are on the same line
  def stations_on_same_line?(station1, station2)
    @lines.each do |line|
      if line.contains_station?(station1) && line.contains_station?(station2)
        return true
      end
    end
    return false
  end

  #This method basically adds in the instructions to change trains/lines
  # 'route' is an array of stations, no two stations can have the same 
  # name, a repeat of a station in a route indicates a line hop
  def interpret_route(route)
  #  example input: ["w", "s", "s", "z", "ab"]
  #  example output:["w", "s", "change to the line7 line", "z", "ab"]
    route.each_with_index do |station, index| 
      if route[index-1] == station # Then there was a line hop
        # determine what the new line is
        @lines.each do |line|
          if line.contains_station?(station) && line.contains_station?(route[index+1])
            route[index] = "change to the #{line.name} line"
            break
          end
        end
        # This logic could be problematic if the 
        # first and last elements of the array are the same station, 
        # but I'm making an assumption that such an array won't be 
        # passed to it.
      end
    end
  end

  #this method basically converts the route array into a single string 
  # that (hopefully) makes more sense
  #  example input:  ["w", "s", "change to the line7 line", "z", "aa"]
  #  example output: "w ~> s ~> change to the line7 line ~> z ~> aa"
  def get_readable_route(route_as_array)
    readable_route = ''
    route_as_array.each do |step|
      unless step == route_as_array.last
        readable_route += step + " ~> "
      else
        readable_route += step
      end
    end
    readable_route
  end

end # class RouteFinder


# This represents a line coordinator person that looks at a 
  # map and determines which stations are junction stations.
class LineManager
  
  # this function modifies the Line objects that are passed to it in the array.
  def determine_neighbours_and_junctions(array_of_lines)
    # for every train line,
    array_of_lines.each_with_index do |line, line_index|
      # go through all of its stations,
      line.stations.each do |station|
        # and check if the station is also in any of the 
          # other lines by checking every line
        array_of_lines.each_with_index do |other_line, other_lines_index|
          # except this one
          unless other_lines_index == line_index
            # for if it contains the station:
            if other_line.contains_station?(station)
              # and if so, adding it to this line's list of neighbours 
                # and adding the station to the list of stations that are 
                # a junction between two lines.
              line.neighbour_lines << other_line
              line.junction_stations << station
            end
          end
        end # array_of_lines.each_with_index do |other_line, other_lines_index|
      end # line.stations.each do |station|
        # if a junction is a junction of more than two lines, it will have
        #   been duplicated by the above code so remove duplicates 
        #   as a precaution:
        line.junction_stations.uniq!
    end # array_of_lines.each_with_index do |line, line_index|
  end # def determine_neighbours_and_junctions(array_of_lines)
end # class LineManager


# Dummy test data:
# Generate lines:
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

rf = RouteFinder.new(lines)
# Make a new route finder for our array of lines and then test it:
route_that_jumps_multiple_lines = rf.get_route('w','a')

puts route_that_jumps_multiple_lines
