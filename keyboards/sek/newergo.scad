include <../../lib/screwpost.scad>
include <../../lib/switch.scad>
include <../../lib/dsacaps.scad>

// Larger values can be used for aesthetic reasons.
wall_thickness = 1.75;

// Different methods of making space inside the shell.
internal_space = 0; // [0:By perimeter, 1:By key position]

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
height_diff = rad * (1 - cos(asin((key_space / 2) / rad)));

screwpos = [
	[0, key_space + cols[0][0]],
	[key_space, (key_space * cols[0][1]) + cols[0][0]],
	[key_space * (len(cols) - 1), key_space * cols[len(cols) - 1][1]],
	[key_space * len(cols), key_space + cols[len(cols) - 1][0]],
];

feetpos = [
	[-rtop + rfeet, rfeet + cols[0][0]],
	[key_space, curvey(2.5 * key_space) - rfeet - wt],
	[key_space * (len(cols) - 1), curvey(2.5 * key_space) - rfeet - wt],
	[key_space * len(cols) + rtop - rfeet, rfeet + cols[len(cols) - 1][0]],
];

// These functions find a point on the outer curve given the offset from the center
function curvey(pos) = key_space * 4
                      + sqrt((rad * rad) - (pos * pos)) * sc
                      + height_diff * sc;
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

	// Position of TRRS jack from beginning of curve
	pos = key_space * 1.5;

	union()
	{
		difference()
		{
			// Main shell
			translate([0, 0, -bottom_thickness]) newershell(shellh + bottom_thickness, r);

			if(internal_space == 0)
				newershell(shellh, r - wt);
			else if(internal_space == 1)
			{
				hull()
					for(x = [0:len(cols) - 1])
						translate([key_space * x, cols[x][0]])
							cube([key_space, key_space * cols[x][1], shellh]);
				for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
					screwhole();
			}


			// TRRS jack hole
			translate([curvex(pos), curvey(pos), 4.5]) rotate([90, 0]) cylinder(wt * 3, 4, 4);
			translate([curvex(pos), curvey(pos - 5.5) - wt + 1, 4.5]) rotate([-90, 0]) cylinder(wt, 5.5, 5.5);

			translate([center, ((key_space * cols[tallestcol][1]) + cols[tallestcol][0]) / 2, -0.2])
				linear_extrude(0.2) text("https://github.com/Riksu9000/mkb", halign="center", valign="center", size=6);

			// Feet on bottom
			for(i = [0 :len(feetpos) - 1]) translate(feetpos[i])
				translate([0, 0, -bottom_thickness]) cylinder(bottom_thickness, rfeet, rfeet);

			// Micro USB-port
			translate([curvex(-4), curvey(0), 0.75]) rotate(-90) cube([wt * 2, 8, 4]);
			translate([curvex(-9.5), curvey(0) - wt]) rotate(-90) cube([34, 19, 4.75]);
			translate([curvex(-8), curvey(0) - wt + 1, -4 + 0.75]) cube([16, wt, 12]);
		}

		// Pro micro holder
		translate([curvex(-11.5), curvey(-11.5) - 34 - (wt / 2)])
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
	height_diff = (center + r) * (1 - cos(asin((key_space / 2) / (center + r))));
	sc = (((cols[tallestcol][1] - 4) * key_space) + cols[tallestcol][0] + r - rtop) / (center + r);

	shellshape = [
		[0, rtop + cols[0][0]],
		[0, key_space * 4],
		[key_space * len(cols), cols[len(cols) - 1][0] + rtop],
		[key_space * (len(cols) - 1), cols[len(cols) - 1][0] + rtop],
		[key_space * len(cols), key_space * 4],
	];

	hull()
	{
		for(i = [0:len(shellshape) - 1]) translate(shellshape[i]) cylinder(h, r, r);
		translate([center, (key_space * 4) + (height_diff * sc)]) scale([1, sc]) cylinder(h, center + r, center + r, $fn = $fn * 4);
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
