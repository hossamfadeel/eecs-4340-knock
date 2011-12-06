`define NSMO (`NOC_SIZE-1) 

`define TOP(y) y==0
`define BOTTOM(y) y==`NSMO
`define LEFT(x) x==0
`define RIGHT(x) x==`NSMO

`define INDEX(x,y) x+(y*`NOC_SIZE)+1
`define NORTH(x,y) `INDEX(x,y)+(`NSMO*(y-1))-1
`define SOUTH(x,y) `INDEX(x,y)+(`NSMO*(y+1)) 
`define EAST(x,y) `INDEX(x,y)+(`NSMO*y)
`define WEST(x,y) `INDEX(x,y)+(`NSMO*y)-1 
