vlib project

# RAM
vlog ram/ram160x80x3.v

# VGA
vlog vga_adapter/vga_vpi.v

# Main project v files
vlog -hazards -lint -nologo -printinfilenames -quiet objects.v draw.v datapath.v main_control.v main.v

vsim -title "CSC258 Project" -Lf C:/altera/15.0/modelsim_ase/altera/verilog/altera_mf main

add log {/*}

# Add waves

add wave -divider "Clocks and Speed"
add wave -color #FFC400 {/main/CLOCK_50}
add wave -color #FFC400 {/main/d0/clock}
add wave -color #FFC400 {/main/d0/rate_div/clock}
add wave -color #FFC400 -unsigned {/main/cycles_per_frame}

add wave -divider "Inputs"
add wave -color #008CFF {/main/SW[9:7]}
add wave -color #008CFF {/main/KEY[0]}
add wave -color #008CFF {/main/KEY[1]}

add wave -divider "VGA Outs"
add wave -color #FF00EA {/main/colour}
add wave -color #FF00EA -unsigned {/main/x}
add wave -color #FF00EA -unsigned {/main/y}

add wave -divider "States"
add wave -color #00FF08 -unsigned {/main/core_state}
add wave -color #00FF08 -unsigned {/main/play_state}
add wave -color #00FF08 {/main/s_next_frame}
add wave -color #00FF08 {/d0/rate_elapsed}

add wave -divider "Scroll Logic"
add wave -color #EA73FF {/d0/buffer_write}
add wave -color #EA73FF {/d0/next_object_distance}
add wave -color #EA73FF -unsigned {/d0/scroll_pixels/object/random_value}

add wave -divider "DP Colours"
add wave -color #00FFB3 {/d0/buffer_colour_in}
add wave -color #00FFB3 {/d0/buffer_colour_out}
add wave -color #00FFB3 {/d0/wait_colour}
add wave -color #00FFB3 {/d0/scroll_colour}

# Resetting signals.

force {/main/CLOCK_50} 1 0, 0 20ns -repeat 40ns
force {/main/SW[9:7]} 0
force {/main/KEY[0]} 1
force {/main/KEY[1]} 1
run 20ns

force {/main/KEY[0]} 0
run 20ns

force {/main/KEY[0]} 1
run 20ns

# 1000000 ns
run 1000000ns

force {/main/KEY[1]} 0
run 20ns

force {/main/KEY[1]} 1
run 20ns

# 1 ms.
run 100000000ns
