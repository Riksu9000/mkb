include <../../lib/screwpost.scad>
include <../../lib/switch.scad>
include <../../lib/dsacaps.scad>

// Larger values can be used for aesthetic reasons.
wall_thickness = 1.75;

$fn = 24; // [8:8.Draft, 24:24.Proto, 72:72.Export]

/* [Hidden] */

bottom_thickness = 1;

rfeet = 10;

// Extra clearance between keycaps and walls
keycap_clearance = 0.25;

// Clearance for processor and handwiring
promicroclearance = 4;
shellh = 9 - plate_thickness + promicroclearance;

// Thickness of shell is wt, while minimum thickness of walls around switches are wall_thickness
wt = max(2, wall_thickness + keycap_clearance);

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

center = (len(cols) / 2) * key_space;
rad = center + rtop + wt;
sc = (((cols[tallestcol][1] - 4) * key_space) + cols[tallestcol][0] + wt) / rad;
hi = rad * (1 - cos(asin((key_space / 2) / rad)));

screwpos = [
	[0, key_space],
	[key_space, key_space * cols[0][1]],
	[key_space * (len(cols) - 1), key_space * cols[len(cols) - 1][1]],
	[key_space * len(cols), key_space + cols[len(cols) - 1][0]],
];

feetpos = [
	[-rtop + rfeet, rfeet],
	[key_space, curvey(2.5 * key_space) - rfeet - wt],
	[key_space * (len(cols) - 1), curvey(2.5 * key_space) - rfeet - wt],
	[key_space * len(cols) + rtop - rfeet, rfeet + cols[len(cols) - 1][0]],
];

// These functions find a point on the outer curve given the offset from the center
function curvey(pos) = key_space * 4
                      + sqrt((rad * rad) - (pos * pos)) * sc
                      + hi * sc;
function curvex(pos) = center + pos;

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
			translate([(key_space * x) - keycap_clearance, cols[x][0] - keycap_clearance, plate_thickness])
				cube([key_space + (keycap_clearance * 2), key_space * cols[x][1] + (keycap_clearance * 2), wallh]);
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
	pos = key_space - (rjack * 2);

	union()
	{
		difference()
		{
			// Main shell
			translate([0, 0, -bottom_thickness]) newershell(shellh + bottom_thickness, r);
			newershell(shellh, r - wt);

			// TRRS jack hole
			translate([curvex(pos), curvey(pos) - wt])
			{
				translate([rjack * 2, 0, 3 + 1]) rotate([-90, 0]) cylinder(wt, rjack, rjack);
				translate([rjack * 2, 1, 3 + 1]) rotate([-90, 0]) cylinder(wt, 2 * rjack, 2 * rjack);
				rotate(-90) cube(4 * rjack);
			}

			translate([key_space * (len(cols) / 2), ((key_space * cols[tallestcol][1]) + cols[tallestcol][0]) / 2, -0.2])
				linear_extrude(0.2) text("https://github.com/Riksu9000/mkb", halign="center", valign="center", size=6);

			// Feet on bottom
			for(i = [0 :len(feetpos) - 1]) translate(feetpos[i])
				translate([0, 0, -bottom_thickness]) cylinder(bottom_thickness, rfeet, rfeet);

			// Micro USB-port
			translate([key_space * len(cols) / 2, (key_space * cols[tallestcol][1]) + cols[tallestcol][0] + (wt / 2), 2.75])
			{
				cube([8, wt, 4], center=true);
				translate([0, 1]) cube([16, wt, 12], center=true);
			}
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
	hi = (center + r) * (1 - cos(asin((key_space / 2) / (center + r))));
	sc = (((cols[tallestcol][1] - 4) * key_space) + cols[tallestcol][0] + r - rtop) / (center + r);

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
		translate([center, (key_space * 4) + (hi * sc)]) scale([1, sc]) cylinder(h, center + r, center + r, $fn = $fn * 4);
	}
}

// Renders

// testing curve functions
//for(i = [0:center])
//	translate([curvex2(i), curvey2(i)])
//		cylinder(10, 1, 1);

color("#74b")
{
	translate([0, 0, -shellh]) shell();
	plate();
}

// Show keycaps in preview mode
%dsacaps();
