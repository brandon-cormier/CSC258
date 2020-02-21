vlib work
vmap work "D:/Noah/Documents/School/CSC258 - Proj/csc258-project/work"
vlog ram/ram160x80x3_bb.v
vlog vga_adapter/vga_vpi.v
vlog datapath.v
vlog draw.v
vlog main.v
vlog main_control.v
vlog objects.v

vsim main

add list {/main/VGA/resetn}
add list {/main/VGA/plot}
add list {/main/VGA/x}
add list {/main/VGA/y}
add list {/main/VGA/colour}

add wave {/main/VGA/resetn}
add wave {/main/VGA/plot}
add wave {/main/VGA/x}
add wave {/main/VGA/y}
add wave {/main/VGA/colour}

force -freeze {CLOCK_50} 1 0, 0 {50 ps} -r 100
force {KEY[1]} 1
force {KEY[0]} 1
run 100ps
force {KEY[0]} 0
run 100ps
force {KEY[0]} 1
run 100ps