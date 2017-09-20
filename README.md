# Solution to problem 20
## ...of Matt's Ruby Fundamentals challenges

## Problem:

Think about coding a basic PTV app (like our public transport app, if you aren't familiar). The final product would take a user input of an origin station, and a destination station, and return a data structure that contains the stops to pass through, and the line changes if required. Perhaps restrict the user input so there cannot be an error returned (the only stations they choose are valid - or assume this, but say if that's your choice). Start with one train line, represented by an array. If you extend it to two lines, you need to think about how to represent the lines as data, and this might be a complex object. 

## My solution:

I wanted to have a solution that would work with more than just one or two lines of stations and settled on having a go using a recursive algorithm to find a path, partly for the practice of working with recursion (the last time I put it to use was probably at uni).

You can make the lines join in many ways but if there is a loop in the tracks I would make the representation such that there didn't seem to be a loop in a line such as illustrated below:

![Metro map with lines declared with colours](/metro-no-loop.jpg)

### Strengths:

* Works for practically any number of lines.
* Works if the lines are changed frequently.
* Easy setup of the train network, literally just declare lines as arrays of stations.

### Weaknesses

* Doesn't guarantee the most optimum route where multiple routes are possible.
* The route finding algorithm would be considered very inefficient as it does calculations each time a route is requested.

### Conclusions

Given that a train network's lines practically never change, there would be more optimal solutions that take advantage of that assumption and use a miniscule amount *more* data storage to vastly speed up the response time and resources needed per query. One possible approach might be to store extra information against each station, such that when a route is being determined, each station could be queried about the final destination and the station could respond with a directive to *"go that way"*.
