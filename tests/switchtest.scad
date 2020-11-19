include <../lib/switch.scad>

/* This is the extra distance between keycap and side wall. Increase the value
 * if your keycaps are touching the side walls. */
key_clearance = 0.25;

wall_height = 7;

wall_thickness = 1.75;

render()
	difference()
	{
		translate([-key_clearance - wall_thickness, -key_clearance - wall_thickness])
			cube([key_space + (key_clearance * 2) + (wall_thickness * 2), key_space + (key_clearance * 2) + (wall_thickness * 2), plate_thickness + wall_height]);
		translate([-key_clearance, -key_clearance, plate_thickness])
			cube([key_space + (key_clearance * 2), key_space + (key_clearance * 2), plate_thickness + wall_height]);
		switch();
	}
