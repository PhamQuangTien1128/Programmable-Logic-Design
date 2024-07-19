module test(output reg [6:0] hex0, 
            output reg [6:0] hex1, 
            output reg [6:0] hex2, 
            output reg [6:0] hex3, 
            input [1:0] key, 
            input clock);
            
reg [24:0] counter;
reg [19:0] flag_counter;
reg [11:0] counter_sec;
reg [7:0] chuc_min, donvi_min;
reg [7:0] chuc_sec, donvi_sec;
reg key_flag;
reg stop;
wire [27:0] c;

initial begin
	flag_counter[19:0] = 20'b0;
	counter_sec[11:0] = 12'b0;
	stop = 1'b0;
end

hexDecode U3 (.a(chuc_min), .b(c[27:21]));
hexDecode U2 (.a(donvi_min), .b(c[20:14]));
hexDecode U1 (.a(chuc_sec), .b(c[13:7]));
hexDecode U0 (.a(donvi_sec), .b(c[6:0]));


always @(posedge clock)
	counter <= counter + 1'b1;

always @(posedge counter[6], negedge key[0], negedge key[1])
begin
    if(key[0] == 1'b0)
    begin
        counter_sec <= 12'b0; flag_counter <= 20'b0;
    end
    else
    begin
        if(key[1] == 1'b0)
            key_flag <= 1'b1;
        else
        begin
            if(key_flag)
            begin
                stop <= stop ^ 1'b1;
                counter_sec <= counter_sec; 
                flag_counter <= 20'b0;
                key_flag <= 1'b0;
            end
            else
            begin
                if(stop)
                begin
                    counter_sec <= counter_sec; 
                    flag_counter <= 20'b0;
                end
                else
                begin
                    if(flag_counter == 20'h5f5e1)
                    begin
                        if(counter_sec == 12'd3600)
                            counter_sec <= 12'b0;
                        else
                            counter_sec <= counter_sec + 1'b1;
                        flag_counter <= 20'b0;
                    end
                    else
                        flag_counter <= flag_counter + 1'b1;
                end
            end
        end
    end
    
    chuc_min <= (counter_sec / 8'd60) / 4'd10;
    donvi_min <= (counter_sec / 8'd60) % 4'd10;
    chuc_sec <= (counter_sec % 8'd60) / 4'd10;
    donvi_sec <= (counter_sec % 8'd60) % 4'd10;
    
    hex0 <= c[6:0];
    hex1 <= c[13:7];
    hex2 <= c[20:14];
    hex3 <= c[27:21];
end
endmodule

module hexDecode(input [3:0] a, output reg [6:0] b);
    always @(a)
        case (a)
            4'd0: b <= 7'b1000000;
            4'd1: b <= 7'b1111001;
            4'd2: b <= 7'b0100100;
            4'd3: b <= 7'b0110000;
            4'd4: b <= 7'b0011001;
            4'd5: b <= 7'b0010010;
            4'd6: b <= 7'b0000010;
            4'd7: b <= 7'b1111000;
            4'd8: b <= 7'b0000000;
            4'd9: b <= 7'b0010000;
        endcase
endmodule