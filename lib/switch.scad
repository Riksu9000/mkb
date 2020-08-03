/* These values can be changed inside the project if necessary */
key_space = 19.05;
plate_thickness = 3;

/* Shape options are "simple" and "complex".
 * The "simple" shape might be easier to print at an angle, but otherwise "complex" is recommended */
module switch(h = plate_thickness, shape = "complex", rotation = 0)
{
	OPENING_DEPTH  = 0.8;
	OPENING_HEIGHT = 3.5;
	SIDE = 14;
	TAB_DEPTH = 0.6;
	TAB_HEIGHT = 1.5;
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
							translate([-OPENING_DEPTH, 1])                         cube([SIDE + (OPENING_DEPTH * 2), OPENING_HEIGHT, h]);
							translate([-OPENING_DEPTH, SIDE - 1 - OPENING_HEIGHT]) cube([SIDE + (OPENING_DEPTH * 2), OPENING_HEIGHT, h]);
						}
						translate([(SIDE / 2) - (TAB_WIDTH / 2), -TAB_DEPTH]) cube([TAB_WIDTH, TAB_DEPTH + SIDE + TAB_DEPTH, h - TAB_HEIGHT]);
					}
}

//switch();
