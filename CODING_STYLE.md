# Verilog coding style

The RTL and testbenches in this revision follow the style used in the original
uploaded project.

## Module declaration

```verilog
module example(clk,rst,data_in,data_out);
    input clk,rst;
    input [31:0] data_in;
    output reg [31:0] data_out;
```

## Procedural blocks

```verilog
always@(posedge clk)
    begin
        if(rst)
            begin
                data_out<=32'b0;
            end
        else
            begin
                data_out<=data_in;
            end
    end
```

## Module instantiation

```verilog
example block(.clk(clk),
              .rst(rst),
              .data_in(source_data),
              .data_out(result_data));
```

Nonblocking assignments are used in clocked blocks. Blocking assignments are
used in combinational blocks. Comments are added only where they identify an
important instruction group, interface boundary, or verification condition.
