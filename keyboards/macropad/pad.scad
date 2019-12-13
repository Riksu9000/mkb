include <../../lib/switch.scad>
include <../../lib/screwpost.scad>

width = 5;
height = 3;
wall_thickness = 2;

/* [Hidden] */

$fn = 24; // [8:8.Draft, 24:24.Proto, 72:72.Export]

/* [Hidden] */

bottom_thickness = 1;
wallh = 7;

// Extra clearance between keycaps and walls
keycap_clearance = 0.25;

// Thickness of shell is wt, while minimum thickness of walls around switches are wall_thickness
wt = max(2, wall_thickness + keycap_clearance);

rscrew = 1.5;
rtop   = 3;

// Clearance for processor and handwiring
promicroclearance = 4;
shellh = 9 - plate_thickness + promicroclearance;

screwpos = [
	[key_space, key_space],
	[key_space, (height - 1) * key_space],
	[(width - 1) * key_space, (height - 1) * key_space],
	[(width - 1) * key_space, key_space],
];

module plate()
{
	difference()
	{
		shape(plate_thickness + wallh);
		translate([-keycap_clearance, -keycap_clearance, plate_thickness]) cube([(key_space * width) + (keycap_clearance * 2), (key_space * height) + (keycap_clearance * 2), wallh]);

		for(x = [0:width - 1], y = [0:height - 1])
			translate([key_space * x, key_space * y]) switch();
	
		for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
			cylinder(plate_thickness, rscrew, rscrew);
	}
}

module shell()
{
	difference()
	{
		translate([0, 0, -bottom_thickness]) shape(shellh + bottom_thickness);
		shape(shellh, 0);
		//cube([key_space * width, key_space * height, shellh]);
	}
	for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
		screwpost();
}

module shape(h, r = wt)
{
	shellshape = [
		[0, 0],
		[0, height * key_space],
		[width * key_space, height * key_space],
		[width * key_space, 0],
	];

	if(r == 0)
		cube([key_space * width, key_space * height, plate_thickness + h]);
	else
		hull()
			for(i = [0:len(shellshape) - 1])
				translate(shellshape[i])
					cylinder(h, r, r);
}

translate([0, 0, shellh]) plate();
shell();
