/* These values can be changed inside the project if necessary */
key_space = 19.05;
plate_thickness = 3;

/* Shape options are "simple" and "complex".
 * The "simple" shape might be easier to print at an angle, but otherwise "complex" is recommended */
module switch(h = plate_thickness, shape = "complex", rotation = 0)
{
	SIDE = 14;
	TAB_HEIGHT = 1.5;
	TAB_DEPTH = 1;
	TAB_WIDTH = 5;
	translate([key_space / 2, key_space / 2])
		rotate(rotation)
			translate([-key_space / 2, -key_space / 2])
				translate([(key_space - SIDE) / 2, (key_space - SIDE) / 2])
					union()
					{
						cube([SIDE, SIDE, h]);
						if(shape == "complex")
						{
							translate([-0.8, 1])              cube([SIDE + 1.6, 3.5, h]);
							translate([-0.8, SIDE - 1 - 3.5]) cube([SIDE + 1.6, 3.5, h]);
						}
						translate([(SIDE / 2) - (TAB_WIDTH / 2), -TAB_DEPTH]) cube([TAB_WIDTH, TAB_DEPTH, h - TAB_HEIGHT]);
						translate([(SIDE / 2) - (TAB_WIDTH / 2), SIDE])       cube([TAB_WIDTH, TAB_DEPTH, h - TAB_HEIGHT]);
					}
}

//switch();
