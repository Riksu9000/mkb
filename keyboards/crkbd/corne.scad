include <../../lib/screwpost.scad>
include <../../lib/switch.scad>
include <../../lib/dsacaps.scad>

/*
up 4.75
up 2.375
down 2.375
down 2.375

center thumb down from middle finger 22mm
center thumb right from middle finger 9.5mm

next thumb rotation 15deg
next thumb right 21mm
next thumb down 2.75mm

last thumb rotation 60deg
last thumb right 22.25mm
last thumb down 3.75mm
*/

// Larger values can be used for aesthetic reasons.
wall_thickness = 1.75;

$fn = 24; // [8:8.Draft, 24:24.Proto, 72:72.Export]

previewcaps = 0; // [0:False,1:True]

/* [Hidden] */

bottom_thickness = 1;

rfeet = 10;

// Extra clearance between keycaps and walls
key_clearance = 0.25;

// Clearance for processor and handwiring
promicroclearance = 4;
shellh = max(9 - plate_thickness, promicroclearance);

// Thickness of shell is wt, while minimum thickness of walls around switches are wall_thickness
wt = max(2, wall_thickness + key_clearance);


rscrew = 1.5;
rtop   = 3;

/* Height of walls around switches
 * 0 is floating keys
 * 7 hides switches completely even on DSA-caps */
wallh = 7;

cols = [
	[0, 3],
	[0, 3],
	[4.75, 3],
	[4.75 + 2.375, 3],
	[4.75, 3],
	[4.75 - 2.375, 3],
];

thumbkeys = [
	[(key_space * 3) + 9.5, cols[3][0] - 22],
	[(key_space * 3) + 9.5 + 21, cols[3][0] - 22 - 2.75],
	[(key_space * 3) + 9.5 + 21 + 22.25, cols[3][0] - 22 - 2.75 - 3.75]
];
thumbkeyrot = [0, -15, 60];
thumbkeysize = [1, 1, 1.5];

screwpos = [
	[key_space, key_space],
	[key_space, key_space * 2],
	[thumbkeys[2][0] + key_space / 2 - sin(thumbkeyrot[2]) * (key_space / 2 + rscrew), thumbkeys[2][1] + key_space / 2 + cos(thumbkeyrot[2]) * (key_space / 2 + rscrew)],
	[key_space * 5, key_space * 2 + (cols[4][0] + cols[5][0]) / 2],
];

p = $preview ? -0.1 : 0;

key_space = 19;

module plate()
{
	difference()
	{
		shape(plate_thickness + wallh, wt);
		translate([0, 0, plate_thickness]) shape(plate_thickness + wallh, key_clearance);
		// switch holes
		for(x = [0:len(cols) - 1])
		{
			for(y = [0:cols[x][1] - 1])
				translate([key_space * x, (key_space * y) + cols[x][0], p])
					switch(plate_thickness + ($preview ? 1: 0));
		}
		for(i = [0:len(thumbkeys) - 1])
			translate(thumbkeys[i])
				switch(plate_thickness + ($preview ? 1: 0), rotation = thumbkeyrot[i]);
		// Micro USB
		translate([xpos - wt - 9.5 - 7, (key_space * cols[5][1]) + 1, 0.75 - 3 - shellh]) cube([14, wt, 10]);

		// TRRS jack hole
		translate([xpos - wt,     (key_space * cols[5][1]) - 34 - 5.5, 5.5 - shellh]) rotate([90, 0, 90]) cylinder(wt, 4, 4);
		translate([xpos - wt + 1, (key_space * cols[5][1]) - 34 - 5.5, 5.5 - shellh]) rotate([90, 0, 90]) cylinder(wt, 5.5, 5.5);

		// Screw holes
		for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
		{
			cylinder(plate_thickness + ($preview ? 1: 0), rscrew, rscrew);
			translate([0, 0, plate_thickness])
				cylinder(wallh + ($preview ? 1: 0), rtop, rtop);
		}
	}
}

module shell()
{
	union()
	{
		difference()
		{
			shape(shellh + bottom_thickness, wt, 1);
			translate([0, 0, bottom_thickness]) shape(shellh, 0, 1);

			// Micro USB
			translate([xpos - wt - 9.5 - 4, (key_space * cols[5][1]), bottom_thickness + 0.75]) cube([8, wt, 4]);
			translate([xpos - wt - 9.5 - 7, (key_space * cols[5][1]) + 1, bottom_thickness + 0.75 - 3]) cube([14, wt, 10]);

			// TRRS jack hole
			translate([xpos - wt,     (key_space * cols[5][1]) - 34 - 5.5, 5.5 + bottom_thickness]) rotate([90, 0, 90]) cylinder(wt, 4, 4);
			translate([xpos - wt + 1, (key_space * cols[5][1]) - 34 - 5.5, 5.5 + bottom_thickness]) rotate([90, 0, 90]) cylinder(wt, 5.5, 5.5);
		}
		translate([xpos - 21 - wt, (key_space * cols[5][1]) - 34, bottom_thickness])
			cube([2, 34, 1]);
		for(i = [0:len(screwpos) - 1])
			translate([screwpos[i][0], screwpos[i][1], bottom_thickness])
				screwpost(shellh);
	}
}

// Pro micro holder test
xpos = thumbkeys[2][0] + (key_space / 2) + cos(thumbkeyrot[2]) * ((key_space * (thumbkeysize[2] / 2)) + wt) + sin(thumbkeyrot[2]) * ((key_space / 2) + wt);
//translate([xpos - 21 - wt, (key_space * cols[5][1]) + cols[5][0] - 34, 3])
//{
//	cube([2, 34, 1]);
//	translate([2 + 19, 0]) cube([2, 34, 1]);
//}

module shape(h, padding, part = 0)
{
	// TODO: Right side is too thick
	xpos = thumbkeys[2][0] + (key_space / 2) + cos(thumbkeyrot[2]) * ((key_space * (thumbkeysize[2] / 2)) + wt) + sin(thumbkeyrot[2]) * ((key_space / 2) + wt);
	ypos = thumbkeys[2][1] + (key_space / 2) + sin(thumbkeyrot[2]) * ((key_space * (thumbkeysize[2] / 2)) + wt) - cos(thumbkeyrot[2]) * ((key_space / 2) + wt);;

	union()
	{
		for(i = [0:len(cols) - 1])
			translate([(i * key_space) - padding, cols[i][0] - padding])
				cube([key_space + padding + padding, (cols[i][1] * key_space) + padding + padding, h]);
		translate([(key_space / 2), (key_space / 2), h / 2])
			for(i = [0:len(thumbkeys) - 1])
				translate(thumbkeys[i])
					rotate(thumbkeyrot[i])
						/*
						 * TODO: Conditionals below are dirty hacks
						 */
						translate([(i != 2 ? .2 : 0) * key_space, key_space * 0.2])
							cube([((i != 2 ? 1.4 : 1.0) * key_space * thumbkeysize[i]) + padding + padding, (key_space * 1.4) + padding + padding, h], center=true);
		/*
		 * TODO: if statement below is a dirty hack
		 */
		if(part == 0)
			translate([xpos + padding - wt, (((padding != wt) && (part == 0)) ? (cos(thumbkeyrot[2]) * (key_space + wt + wt)) : 0) + ypos, ((padding != wt) && (part == 0)) ? - plate_thickness - plate_thickness : 0])
				rotate(90)
					cube([-ypos + (key_space * cols[5][1]) + padding - (((padding != wt) && (part == 0)) ? (cos(thumbkeyrot[2]) * (key_space + wt + wt)) : 0), xpos - (key_space * 6) - wt - wt + padding, h]);
		else
			translate([xpos + padding - wt, ypos, ((padding != wt) && (part == 0)) ? - plate_thickness - plate_thickness : 0])
				rotate(90)
					cube([-ypos + (key_space * cols[5][1]) + padding, xpos - (key_space * 6) - wt + padding, h]);
	}
}

//color("#74b")
{
	plate();
	translate([0, 0, -shellh - bottom_thickness]) shell();
}

// Show keycaps in preview mode
%if(previewcaps)
{
	dsacaps();
	for(i = [0:len(thumbkeys) - 1])
		translate([thumbkeys[i][0], thumbkeys[i][1], 10])
			dsacap(unit = thumbkeysize[i], rotation = thumbkeyrot[i]);
}
