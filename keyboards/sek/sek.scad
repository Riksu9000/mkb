include <../../lib/screwpost.scad>
include <../../lib/switch.scad>
include <../../lib/dsacaps.scad>

clean_sides = true;

/* [Preview] */

previewcaps = false;

/* [Hidden] */

plate_rev = "R2";
shell_rev = "R2";

wallh = 7;

bottom_thickness = 1;

// Extra clearance between keycaps and walls
key_clearance = 0.25;

// Clearance for processor and handwiring
promicroclearance = 4;
shellh = 9 - plate_thickness + promicroclearance;

/* Thickness of shell is wt, while minimum thickness of walls around switches
 * are wall_thickness
 */
wall_thickness = 1.75;
wt = max(2, wall_thickness + key_clearance);

rscrew = 1.45;
rtop   = 3;

cols = [
	[-key_space, 4],
	[0, 4],
	[4, 4],
	[8, 4],
	[4, 4],
	[0, 4],
	[key_space * 0.5, 2],
];

thumb_angle = atan((cols[4][0] - cols[5][0]) / key_space);
tallestcol = 3; // Automate this someday
thumb_offset = cols[4][0] - cols[5][0];

width  = 7 * key_space;
center = width / 2;
height = cols[tallestcol][0] + key_space * cols[tallestcol][1];

nthumbkeys = 4;

screwpos = [
	[key_space, key_space + cols[0][0]],
	[key_space, (key_space * cols[0][1]) + cols[0][0]],
	[width - key_space, key_space * (cols[len(cols) - 2][1] - 1)],
	[width - cos(thumb_angle) * key_space , -sin(thumb_angle) * key_space],
];

top_angle = atan((cols[3][0] - cols[1][0]) / (key_space * 2));

// Currently only used for colorize
layer_height = 0.25;

p = $preview ? 0.1 : 0;

$fn = $preview ? 24 : 72;

// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/undersized_circular_objects
module cylinder_outer(h, r, fn){
	fudge = 1 / cos(180 / fn);
	rotate(180 / fn)
	cylinder(h, r = r * fudge, $fn = fn);
}

module plate()
{
	difference()
	{
		// Base pieces
		shellshape(plate_thickness + wallh, wt);

		// switch holes and space for caps
		for(x = [0:len(cols) - 1])
		{
			for(y = [0:cols[x][1] - 1])
				translate([key_space * x, (key_space * y) + cols[x][0], -p])
					switch(plate_thickness + p*2, corner = "round");
			if(wallh > 0)
			{
				thumbcleaner = clean_sides && x > len(cols) - nthumbkeys - 1 && x < len(cols) - 1 ? 4 : 0;
				translate([(key_space * x) - key_clearance, cols[x][0] - key_clearance - thumbcleaner, plate_thickness])
					cube([key_space + (key_clearance * 2), key_space * cols[x][1] + (key_clearance * 2) + thumbcleaner, wallh + p]);
			}
		}

		// Thumb keys
		translate([width, -thumb_offset - sin(thumb_angle) * key_space])
			rotate(180 - thumb_angle)
				for(i = [0:nthumbkeys - 1])
					translate([key_space * i, 0])
					{
						translate([0, 0, -p])
							switch(plate_thickness + p*2, corner = "round");
						if(wallh > 0)
							translate([-key_clearance, -key_clearance, plate_thickness])
								cube([key_space + (key_clearance * 2), key_space + (key_clearance * 2), wallh + p*2]);
					}

		// Screw holes
		for(i = [0:len(screwpos) - 1])
			translate(screwpos[i])
			{
				cylinder(plate_thickness + p, r = rscrew + 0.05);
				translate([0, 0, plate_thickness])
					cylinder(wallh + p, r = rtop);
			}

		// Part revision
		translate([key_space * 1.5, -key_space / 2])
			linear_extrude(layer_height + p, convexity = 10)
				rotate([0, 180])
					text(shell_rev, halign="center", valign="center", size=6);
	}
}

// Experimental way of coloring the underside of keys
module colorize()
{
	difference()
	{
		linear_extrude(layer_height * 2)
			offset(r = -10 - (wt / 2))
				offset(r = 10)
					projection()
						plate();
		for(x = [0:len(cols) - 1])
			for(y = [0:cols[x][1] - 1])
				translate([key_space * x, (key_space * y) + cols[x][0], -p])
					switch(plate_thickness + p*2);
		// Thumb keys
		translate([width, -thumb_offset - sin(thumb_angle) * key_space])
			rotate(180 - thumb_angle)
				for(i = [0:nthumbkeys - 1])
					translate([key_space * i, 0, -p])
							switch(plate_thickness + p*2);
	}
}

module shell()
{
	union()
	{
		difference()
		{
			// Main shell
			translate([0, 0, -bottom_thickness])
				shellshape(shellh + bottom_thickness, wt);

			difference()
			{
				shellshape(shellh + p, 0);
				// Leave a part inside that holds TRRS jack
				translate([width - (key_space / 2) - 6.5, height - (((key_space * 2.5) + 5.5) * tan(top_angle)) + (wt / cos(top_angle)) - 3.5 - 1.5])
					cube([6.5 + (key_space / 2), wt * 8, shellh]);
			}

			// Hole for switch
			translate([center, height - key_space, -bottom_thickness])
				cylinder(bottom_thickness + p, r = 2);

			// Reset text
			translate([center, height - key_space + 4, -bottom_thickness -p])
				linear_extrude(layer_height, convexity = 10)
					rotate([0, 180])
						text("Reset", halign="center", valign="bottom", size=4);

			// TRRS jack hole
			translate([width - (key_space / 2), height - (((key_space * 2.5) + 5.5) * tan(top_angle)) + (wt / cos(top_angle)) - 3.5, 4.5])
				rotate([-90, 0])
				{
					cylinder_outer(wt * 8, 5.5, $fn);  // cylinder_outer only to fix non-manifold error
					translate([0, 0, -1.51])
						cylinder(4.5 + 0.01, r = 4);
				}

			translate([center, 12, -0.2])
				linear_extrude(layer_height + p, convexity = 10)
					text("https://github.com/Riksu9000/mkb", halign="center", valign="center", size=6);

			// Part revision
			translate([center, 0, -0.2])
				linear_extrude(layer_height + p, convexity = 10)
					text(shell_rev, halign="center", valign="center", size=6);

			// Micro usb hole
			translate([width / 4, height - key_space * 1.25 * tan(top_angle)])
				rotate(top_angle)
				{
					translate([-4, -0.01, 1.75])
						cube([8, wt + 0.01, 3]);
					translate([-8, 1.5, 1.75 - 4])
						cube([16, wt, 11]);
				}
		}

		// Mount for reset switch
		translate([center, height - key_space])
			difference()
			{
				cylinder(3, (3 * sqrt(2)) + 1.5, 3 * sqrt(2));
				translate([-3, -6])
					cube([6, 12, 3 + p]);
			}

		// Pro micro holder
		translate([width / 4, height - key_space * 1.25 * tan(top_angle)])
			rotate(-90 + top_angle)
			{
				translate([0, 9.5])
					cube([34, 2, 1]);
				translate([0, -11.5])
					cube([34, 2, 1]);
			}

		// Screw posts
		for(i = [0:len(screwpos) - 1])
			translate(screwpos[i])
				screwpost(shellh);
	}
}

module shellshape(h, r, hbevel = 0)
{
	// Points go around counter clockwise starting from bottom left point
	points = [
		[0, cols[0][0]],
		[key_space, cols[0][0]],

		[width - sin(thumb_angle) * key_space - cos(thumb_angle) * key_space * nthumbkeys,
		- thumb_offset // Top left corner
		- ((key_space * sin(thumb_angle)) + (cos(thumb_angle) * key_space)) // Bottom left corner
		+ (sin(thumb_angle) * key_space * nthumbkeys)], // Bottom right corner

		[width - sin(thumb_angle) * key_space,
		- thumb_offset // Top left corner
		- ((key_space * sin(thumb_angle)) + (cos(thumb_angle) * key_space))], // Bottom left corner

		[width, -thumb_offset - (key_space * sin(thumb_angle))],

		[width,  height - (key_space * 3   * tan(top_angle))],
		[center, height + (key_space * 0.5 * tan(top_angle))],
		[0,      height - (key_space * 3   * tan(top_angle))],
	];

	linear_extrude(h, convexity = 4)
		minkowski()
		{
			polygon(points);
			if(r > 0)
				circle(r);
		}
}

// Output

translate([0, 0, -shellh - 0.001]) shell();
plate();
//translate([0, 0, plate_thickness - (layer_height * 2) + p])
//	colorize();

// Show keycaps in preview mode
%if(previewcaps)
{
	%dsacaps();
	%color("#222")
		translate([width, -thumb_offset - sin(thumb_angle) * key_space])
			rotate(180 - thumb_angle)
				for(i = [0:nthumbkeys - 1])
					translate([key_space * i, 0, plate_thickness + 7])
						dsacap();
}

//translate([0, 0, -shellh - bottom_thickness])
//	difference()
//	{
//		translate([-wt, -100])
//			cube([width + wt + wt - (sin(top_angle) * key_space), 100, shellh + plate_thickness]);
//		shellshape(shellh + plate_thickness, wt + 0.1);
//	}
