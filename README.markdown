Description:
A collection of useful Twitter Utilities
Tools:
Of primary interest is the graphing tool. It will determine if a 
Twitter user has another user in thier 1st, 2nd or 
3rd degree of connections
Limitations: 
Running 3rd degree checks on users that have a lot of followers/friends 
will result in using all your available API hit. Twitter developer 
account recommended!

Result: the graph method returns a hash of arrays, keyed off the degree of
separation. The value for each key an array of all the connections that exist
at that level. Each connection is described by a series of Twitter IDs
that are ordered by the flow of the connection.

Example: 
tootil = Tootils.new(user, pass)
tootil.graph(sarahr, brookr)
- {1=>[[11146212, 11136022]], 2=>[], 3=>[]}
tootil.graph(sarahr, whitscott)
- {1=>[],
-  2=>
-   [[11146212, 11136022, 9338922],
-    [11146212, 14864296, 9338922],
-    [11146212, 17785160, 9338922],
-    [11146212, 6602252, 9338922],
-    [11146212, 11136252, 9338922]],
-  3=>[]}

tootil.graph(sarahr, pop17)
- {1=>[],
-  2=>[],
-  3=>
-   [[11146212, 11136022, 9338922, 74673],
-    [11146212, 11136022, 813286, 74673],
-    [11146212, 11136022, 5997662, 74673],
-    [11146212, 11136022, 2874, 74673],
-    [11146212, 11136022, 734493, 74673],
-    [11146212, 14864296, 9338922, 74673],
-    ...}
   
Author: 
Brook Riggio
http://twitter.com/brookr

History:
2009-07-15: 
Version .2: "Layout the API"
 – Renamed project Tootils, to make space for other utilities
 – Totally refactored
 – Graph now shows all connections between two users
 – Consistent internal API
 – Renamed links_to to graph
 – Better data structure for graph results
2009-05-26: 
Version .1: "We might have something here"
 – Now checks the 3rd degree as intended
 – Various optimizations to reduce API hits
 – Refactorings!

2009-02-20:
Version 0.0.1: "Proof of concept"
 – Checks first and second degree
 – Uses lots of API hits
 – But keeps track of those API hits used!
