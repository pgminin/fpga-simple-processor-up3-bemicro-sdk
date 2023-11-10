//////////////////////////////////////////////////////////
//Simple Computer Design
// From Hamblen "Rapid prototyping of digital systems"
// Chapter 9
//////////////////////////////////////////////////////////
// ISA:			opcode
// ADD addr		00		
// ST addr		01	
// LD addr		02	
// JMP addr		03	
// JNEG addr	04	
// OUT addr		05
// single 16-bit accumulator
// addr is 8-bits
// for testing, internal busses are exposed
///////////////////////////////////////////////////////////	
module scomp (clock,reset,program_counter,register_A, 
			  memory_data_register_out, instruction_register,out);

   input clock,reset;
   output [7:0] program_counter;
   output [15:0] register_A, memory_data_register_out, instruction_register, out;

   reg  [15:0] register_A,  instruction_register, out;
   reg  [7:0] program_counter;
   reg  [3:0] state;

// State Encodings
parameter	reset_pc 		= 0,
			fetch			= 1,
			decode			= 2,
			execute_add 	= 3,
			execute_store 	= 4,
			execute_store2 	= 5,
			execute_store3 	= 6,
			execute_load	= 7,
			execute_jump	= 8,
			execute_jump_n  = 9,
			execute_out     = 4'ha  ;

	reg [7:0] memory_address_register;
	reg memory_write;
	
	wire [15:0] memory_data_register;
	wire [15:0] memory_data_register_out = memory_data_register;
	wire [15:0] memory_address_register_out = memory_address_register;
	wire memory_write_out = memory_write;

// Use Altsynram function for computer's memory (256 16-bit words)
altsyncram	altsyncram_component (
				.wren_a (memory_write_out),
				.clock0 (clock),
				.address_a (memory_address_register_out),
				.data_a (register_A),
				.q_a (memory_data_register));
	defparam
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.width_a = 16,
		altsyncram_component.widthad_a = 8,
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.lpm_type = "altsyncram",
// Reads in mif file for initial program and data values
		altsyncram_component.init_file = "fibonacci.mif",
		altsyncram_component.intended_device_family = "Cyclone";


   always @(posedge clock or posedge reset)
     begin
        if (reset)
            state = reset_pc;
        else 
			case (state)
// reset the computer, need to clear some registers
       		reset_pc :
       		begin
					program_counter = 8'b00000000;
					register_A = 16'b0000000000000000;
					state = fetch;
					out = 16'h0 ;
       		end
// Fetch instruction from memory and add 1 to program counter
       		fetch :
       		begin
					instruction_register = memory_data_register;
					program_counter = program_counter + 1;
					state = decode;
       		end
// Decode instruction and send out address of any required data operands
       		decode :
       		begin
					case (instruction_register[15:8])
						8'b00000000:
						    state = execute_add;
						8'b00000001:
						    state = execute_store;
						8'b00000010:
						    state = execute_load;
						8'b00000011:
						    state = execute_jump;
						8'b00000100:
						    state = execute_jump_n;
						8'b00000101:
						    state = execute_out;
						default:
						    state = fetch;
					endcase
       		end
// Execute the ADD instruction
       		execute_add :
       		begin
					register_A = register_A + memory_data_register;
					state = fetch;
       		end
// Execute the STORE instruction (needs three clock cycles for memory write)
       		execute_store :
       		begin
// write register_A to memory
 					state = execute_store2;
// This state ensures that the memory address is valid until after memory_write goes low
       		end
       		execute_store2 :
       		begin
				state = execute_store3;
       		end
// Execute the LOAD instruction
       		execute_load :
       		begin
				register_A = memory_data_register;
				state = fetch;
       		end
 // Execute the JUMP instruction
       		execute_jump :
       		begin
				program_counter = instruction_register[7:0];
				state = fetch;
       		end
 // Execute the JUMP A negative instruction      		
       		execute_jump_n :
       		begin
				program_counter = 
					(register_A[15]==1'h1)? instruction_register[7:0] : program_counter ;
				state = fetch;
       		end
 // Execute the OUT instruction      		
       		execute_out :
       		begin
				out = register_A ;
				state = fetch ;
       		end  
 // default is fetch      		    		
       		default :
       		begin
            	state = fetch;
       		end
		endcase
     end
	
	 always @(state or program_counter or instruction_register)
	   begin
		case (state)
			reset_pc: 		memory_address_register = 8'h 00;
			fetch:			memory_address_register = program_counter;
			decode:			memory_address_register = instruction_register[7:0];
			execute_add: 	memory_address_register = program_counter;
			execute_store: 	memory_address_register = instruction_register[7:0];
			execute_store2: memory_address_register = program_counter;
			execute_load:	memory_address_register = program_counter;
			execute_jump:	memory_address_register = instruction_register[7:0];
			execute_jump_n:	memory_address_register = 
							(register_A[15]==1'h1)? instruction_register[7:0] : program_counter ;
			execute_out:	memory_address_register = program_counter;
			default: 		memory_address_register = program_counter;
		endcase
		case (state)
			execute_store: 	memory_write = 1'b 1;
			default:	 	memory_write = 1'b 0;
		endcase
	  end		
endmodule


