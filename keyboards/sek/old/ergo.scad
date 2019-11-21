include <../../../lib/switch.scad>

/* [Hidden] */

bottom_thickness = 1;

rfeet = 10;

// Clearance for processor and handwiring
promicroclearance = 4;

height = 9 - plate_thickness + promicroclearance;

$fn = 24;

tallestcol = 3; // Automate this someday

wall_thickness = 2;

rscrew = 1.5;
rtop   = 3;

cols = [
	[0, 4],
	[key_space, 4],
	[key_space + 5, 4],
	[10, 5],
	[5, 5],
	[3, 5],
	[0, 4],
];

screwpos = [
	[0, key_space],
	[0, (key_space * (cols[tallestcol][1] - 0.5)) + cols[tallestcol][0]],
	[key_space * len(cols), (key_space * (cols[tallestcol][1] - 0.5)) + cols[tallestcol][0]],
	[key_space * len(cols), key_space],
];

feetpos = [
	[key_space * 0.5, key_space * 0.5],
	[key_space * 0.5, (key_space * (cols[tallestcol][1] - 0.5)) + cols[tallestcol][0]],
	[key_space * (len(cols) - 0.5), (key_space * (cols[tallestcol][1] - 0.5)) + cols[tallestcol][0]],
	[key_space * (len(cols) - 0.5), key_space * 0.5],
];

module keycap()
{
	translate([key_space * 0.5, key_space * 0.5, plate_thickness + 7]) rotate(45) cylinder(7.5, 18.25/sqrt(2), 12/sqrt(2), $fn = 4);
}

module plate()
{
	border = 7;
	r = rtop + wall_thickness;

	difference()
	{
		// Base pieces
		newshell(plate_thickness + border, r);

		// switch holes and space for caps
		for(j = [0:len(cols) - 1])
		{
			for(i = [0:cols[j][1] - 1]) translate([key_space * j, (key_space * i) + cols[j][0]]) switch();
			translate([key_space * j, cols[j][0], plate_thickness]) cube([key_space, key_space * cols[j][1], border]);
		}

		// Screw holes
		h = plate_thickness + border;
		for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
		{
			cylinder(border + plate_thickness - 2, rscrew, rscrew);
			translate([0, 0, plate_thickness]) cylinder(border, rtop, rtop);
		}
	}
}

module shell()
{
	r = rtop + wall_thickness;

	h = (key_space * (cols[tallestcol][1] - 0.5)) + cols[tallestcol][0];

	difference()
	{
		shorten = 5;
		union()
		{
			// Bottom
			newshell(bottom_thickness, r);

			// Sides
			translate([0, 0, bottom_thickness]) difference()
			{
				newshell(height, r);
				newshell(height, r - wall_thickness);
				// jack hole
				translate([key_space * (len(cols) - 0.5), key_space * cols[tallestcol][1] + cols[tallestcol][0], height - 4]) rotate([-90, 0]) cylinder(wall_thickness, 4, 4);
			}

			// Pro micro holder
			translate([key_space * len(cols) / 2, (key_space * cols[tallestcol][1]) + cols[tallestcol][0] - 17, bottom_thickness + 0.5])
				cube([23, 34, 1], center=true);

			// Screw posts
			for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
				translate([0, 0, bottom_thickness]) cylinder(height, r, r);

			// Feet on bottom
			for(i = [0:len(feetpos) - 1]) translate(feetpos[i])
				translate([0, 0, bottom_thickness]) cylinder(bottom_thickness, rfeet + bottom_thickness, rfeet);
		}

		// Pro micro holder
		translate([key_space * len(cols) / 2,
		           (key_space * cols[tallestcol][1]) + cols[tallestcol][0] - 17,
		           bottom_thickness + 0.5])
			cube([19, 34, 1], center=true);
		// Micro USB-port
		translate([key_space * len(cols) / 2,
		           (key_space * cols[tallestcol][1]) + cols[tallestcol][0] + (wall_thickness / 2),
		           bottom_thickness + 2.75])
			cube([8, wall_thickness, 4], center=true);

		// Feet on bottom
		for(i = [0 :len(feetpos) - 1]) translate(feetpos[i])
			cylinder(1, rfeet, rfeet);

		// Carve authors name on bottom :)
		translate([key_space * (len(cols) / 2), ((key_space * cols[tallestcol][1]) + cols[tallestcol][0]) / 2, bottom_thickness - 0.2])
			linear_extrude(0.2) text("Riku Isokoski 2019", halign="center", valign="center");

		// Screwholes
		for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
			translate([0, 0, bottom_thickness]) cylinder(height, rscrew, rscrew);

	}
}

module newshell(h, r)
{
	shellshape = [
		[0, rtop],
		[0, (key_space * cols[tallestcol][1]) + cols[tallestcol][0] - rtop],
		[key_space * len(cols), rtop],
		[key_space * len(cols), (key_space * cols[tallestcol][1]) + cols[tallestcol][0] - rtop],
	];

	hull() for(i = [0:len(shellshape) - 1]) translate(shellshape[i])
		cylinder(h, r, r);
}

translate([0, 0, -bottom_thickness - height]) shell();
plate();

//for(j = [0:len(cols) - 1], i = [0:cols[j][1] - 1]) translate([key_space * j, (key_space * i) + cols[j][0]]) keycap();
