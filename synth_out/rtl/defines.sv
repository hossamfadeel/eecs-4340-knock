`define NSMO (`NOC_SIZE-1) 

`define TOP(y) (y)==0
`define BOTTOM(y) (y)==`NSMO
`define LEFT(x) (x)==0
`define RIGHT(x) (x)==`NSMO

`define INDEX(x,y) (x)+((y)*`NOC_SIZE)+1
`define NORTH(x,y) `INDEX(x,y)+(`NSMO*((y)-1))-1
`define SOUTH(x,y) `INDEX(x,y)+(`NSMO*((y)+1)) 
`define EAST(x,y) `INDEX(x,y)+(`NSMO*(y))
`define WEST(x,y) `INDEX(x,y)+(`NSMO*(y))-1 

`define DIR_NORTH 0
`define DIR_SOUTH 1
`define DIR_EAST 2
`define DIR_WEST 3
`define DIR_LOCAL 4

`define GETX(i) (i)%`NOC_SIZE
`define GETY(i) (i)/`NOC_SIZE

`ifdef NOC_MODE
  `define CONVERTER converter_in
`else
  `define CONVERTER converter_out
`endif
