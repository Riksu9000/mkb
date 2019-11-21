key_space = 19.05;
plate_thickness = 3;

module switch(h = plate_thickness)
{
	side = 14;
	tab_height = 1.5;
	tab_depth = 1;
	tab_width = 5;
	translate([(key_space - side) / 2, (key_space - side) / 2]) union()
	{
		cube([side, side, h]);
		translate([-0.8, 1]) cube([side + 1.6, 3.5, h]);
		translate([-0.8, side - 1 - 3.5]) cube([side + 1.6, 3.5, h]);
		translate([(side / 2) - (tab_width / 2), -tab_depth]) cube([tab_width, tab_depth, h - tab_height]);
		translate([(side / 2) - (tab_width / 2), side]) cube([tab_width, tab_depth, h - tab_height]);
	}
}

//switch();
