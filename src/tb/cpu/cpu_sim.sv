`timescale 1ns/1ps

class cpuDriver #(
    parameter HOLD=15
);
    bit [31:0] addr;
    bit read_en;
    bit first_req;
    int unsigned addr_hist[$];

    function new();
        this.read_en = 0;
        this.first_req = 0;
    endfunction

    // function void drive_request_start();
    //     bit hit;
    //     int unsigned addr;
    //     int unsigned idx;
    //     if(this.first_req == 0) begin
    //         $display("cpu drive request start");
    //         this.addr = $urandom_range(32'h0000_0a00, 32'h0000_0aFF);
    //         this.read_en = 1;
    //         this.first_req = 1;
    //     end
    //     else begin
    //         hit = $urandom_range(0, 1);
    //         if(hit) begin
    //             idx = $urandom_range(0, this.addr_hist.size()-1);
    //             this.addr = addr_hist[idx];
    //             this.read_en = 1;
    //         end
    //         else begin
    //             do begin
    //                 this.addr = $urandom_range(32'h0000_0a00, 32'h0000_0aFF);
    //                 this.read_en = 1;
    //             end while (this.addr_hist.find(x) with (x == this.addr) == -1);
    //             this.addr_hist.push_back(this.addr);
    //         end
    //     end
    // endfunction

function void drive_request_start();
  static bit first_request = 1;        // Track if it's the first request
  static int unsigned addr_history[]; // Dynamic array to store address history
  bit hit;                            // Mode: hit or miss
  int unsigned new_addr;

  if (first_request) begin
    // First request must be a miss
    hit = 0;
    first_request = 0;
  end else begin
    // Randomly decide between hit (1) and miss (0)
    hit = $urandom_range(0, 1);
  end

  if (hit && addr_history.size() > 0) begin
    // Generate a "hit" by selecting a random address from the history
    new_addr = addr_history[$urandom_range(0, addr_history.size() - 1)];
  end else begin
    // Generate a "miss" by creating a new random address
    do begin
      new_addr = $urandom_range(32'h0000_0a00, 32'h0000_0aff);
    end while (addr_history.find(x) with (x == new_addr) != -1); // Ensure it’s not in the history
    addr_history.push_back(new_addr);            // Add to history
  end

  // Assign the address and enable the read
  this.addr = new_addr;
  this.read_en = 1;

  // Display the result for debugging
  $display("cpu drive request start: addr = %h, mode = %s", new_addr, hit ? "hit" : "miss");
endfunction

    function void drive_request_end();
        this.addr = 32'd0;
        this.read_en = 0;
        $display("cpu drive request end");
    endfunction

    task automatic drive_request();
        drive_request_start();
        #(HOLD) drive_request_end(); 
    endtask 
endclass


module cpu_sim #(
    parameter REQ_FREQ_CYCLES=10,
    parameter HOLD=15
) (
    ahb_lite.master cpu_intf
);

cpuDriver #(HOLD) driver_obj;

reg [3:0] request_delay_counter; 

    initial begin
        driver_obj = new();
    end

always_ff @( posedge cpu_intf.hclk or negedge cpu_intf.hrstn) begin : read_request
    if(~cpu_intf.hrstn) begin
        request_delay_counter <= 0;
    end
    else begin
        if(request_delay_counter == REQ_FREQ_CYCLES - 1) driver_obj.drive_request();
        request_delay_counter <= request_delay_counter == (REQ_FREQ_CYCLES - 1) ? 0 : request_delay_counter + 1;
    end
end

always begin
    cpu_intf.haddr = driver_obj.addr;
    cpu_intf.hwrite = ~driver_obj.read_en;
    #1;
end

endmodule
