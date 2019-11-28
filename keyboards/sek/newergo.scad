include <../../lib/screwpost.scad>
include <../../lib/switch.scad>
include <../../lib/dsacaps.scad>

// 2mm is the smallest recommended value.  Higher values may be used for aesthetic reasons.
wall_thickness = 2;

/* [Hidden] */

bottom_thickness = 1;

rfeet = 10;

// Extra clearance between keycaps and walls
keycap_clearance = 0.5;

// Clearance for processor and handwiring
promicroclearance = 4;
shellh = 9 - plate_thickness + promicroclearance;

$fn = 24;
//$fn = 72;

wt = wall_thickness + keycap_clearance;

rscrew = 1.5;
rtop   = 3;

/* Height of walls around switches
 * 0 is floating keys
 * 7 hides switches completely even on DSA-caps */
wallh = 7;

cols = [
	[0, 4],
	[key_space, 4],
	[key_space + 5, 4],
	[10, 5],
	[5, 5],
	[0, 5],
	[-5, 4],
];
tallestcol = 3; // Automate this someday

screwpos = [
	[0, key_space],
	[key_space, key_space * cols[0][1]],
	[key_space * (len(cols) - 1), key_space * cols[len(cols) - 1][1]],
	[key_space * len(cols), key_space + cols[len(cols) - 1][0]],
];

feetpos = [
	[key_space * 0.5, key_space * 0.5],
	[key_space, (key_space * (cols[tallestcol][1] - 1.0)) + cols[tallestcol][0]],
	[key_space * (len(cols) - 1), (key_space * (cols[tallestcol][1] - 1.0)) + cols[tallestcol][0]],
	[key_space * (len(cols) - 0.5), key_space * 0.5 + cols[len(cols) - 1][0]],
];

module plate()
{
	r = rtop + wt;
	difference()
	{
		// Base pieces
		newershell(plate_thickness + wallh, r);

		// switch holes and space for caps
		for(x = [0:len(cols) - 1])
		{
			for(y = [0:cols[x][1] - 1]) translate([key_space * x, (key_space * y) + cols[x][0]]) switch();
			translate([(key_space * x) - (keycap_clearance / 2), cols[x][0] - (keycap_clearance / 2), plate_thickness])
				cube([key_space + keycap_clearance, key_space * cols[x][1] + keycap_clearance, wallh]);
		}

		// Screw holes
		for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
		{
			cylinder(plate_thickness, rscrew, rscrew);
			translate([0, 0, plate_thickness]) cylinder(wallh, rtop, rtop);
		}
	}
}

module shell()
{
	r = rtop + wt;

	rjack = 3;

	// Position of TRRS jack from beginning of curve
	pos = (key_space * .5) - (rjack * 2);

	union()
	{
		difference()
		{
			// Main shell
			translate([0, 0, -bottom_thickness]) newershell(shellh + bottom_thickness, r);
			newershell(shellh, r - wt);

			// TRRS jack hole
			translate([key_space * 4 + pos, key_space * 4 + (sqrt(((key_space * 3 + rtop) * (key_space * 3 + rtop)) - (pos * pos)) * ((key_space + cols[tallestcol][0]) / ((key_space * 3) + rtop)))])
			{
				translate([rjack * 2, 0, 3 + 1]) rotate([-90, 0]) cylinder(wt, rjack, rjack);
				translate([rjack * 2, 1, 3 + 1]) rotate([-90, 0]) cylinder(wt, 2 * rjack, 2 * rjack);
				rotate(-90) cube(4 * rjack);
			}

			// Carve authors name on bottom :)
			translate([key_space * (len(cols) / 2), ((key_space * cols[tallestcol][1]) + cols[tallestcol][0]) / 2, -0.2])
				linear_extrude(0.2) text("Riku Isokoski 2019", halign="center", valign="center");

			// Feet on bottom
			for(i = [0 :len(feetpos) - 1]) translate(feetpos[i])
				translate([0, 0, -bottom_thickness]) cylinder(bottom_thickness, rfeet, rfeet);

			// Micro USB-port
			translate([key_space * len(cols) / 2,
					   (key_space * cols[tallestcol][1]) + cols[tallestcol][0] + (wt / 2), 2.75])
				cube([8, wt, 4], center=true);
		}

		// Pro micro holder
		translate([((key_space * len(cols)) / 2) - 11.5, (key_space * cols[tallestcol][1]) + cols[tallestcol][0] - 34])
		{
			cube([2, 34, 1]);
			translate([2 + 19, 0]) cube([2, 34, 1]);
		}

		// Screw posts
		for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
			screwpost(shellh);

		// Feet on bottom
		for(i = [0:len(feetpos) - 1]) translate(feetpos[i])
			cylinder(bottom_thickness, rfeet + bottom_thickness, rfeet);
	}
}

module newershell(h, r)
{
	sc = (((cols[tallestcol][1] - 4) * key_space) + cols[tallestcol][0] + r - rtop) / ((key_space * 3) + r);

	shellshape = [
		[0, rtop],
		[0, key_space * 4],
		[key_space * len(cols), cols[len(cols) - 1][0] + rtop],
		[key_space * (len(cols) - 1), cols[len(cols) - 1][0] + rtop],
		[key_space * len(cols), key_space * 4],
	];

	hull()
	{
		for(i = [0:len(shellshape) - 1]) translate(shellshape[i]) cylinder(h, r, r);
		translate([key_space * 3, key_space * 4]) scale([1, sc]) cylinder(h, (key_space * 3) + r, (key_space * 3) + r, $fn = $fn * 5);
		translate([key_space * 4, key_space * 4]) scale([1, sc]) cylinder(h, (key_space * 3) + r, (key_space * 3) + r, $fn = $fn * 5);
	}
}

// Renders

color("#74b")
{
	translate([0, 0, -shellh]) shell();
	plate();
}

// Show keycaps in preview mode
%dsacaps();
