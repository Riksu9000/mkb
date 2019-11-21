include <../../lib/switch.scad>
include <../../lib/screwpost.scad>

width = 5;
height = 3;
wall_thickness = 2;

/* [Hidden] */

$fn = 24;
//$fn = 72;

bottom_thickness = 1;
wallh = 7;

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
		shape(wallh);
		translate([0, 0, plate_thickness]) cube([key_space * width, key_space * height, wallh]);
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

module shape(h, r = wall_thickness)
{
	shellshape = [
		[0, 0],
		[0, height * key_space],
		[width * key_space, height * key_space],
		[width * key_space, 0],
	];

	if(r == 0)
		cube([key_space * width, key_space * height, plate_thickness + wallh]);
	else
		hull()
			for(i = [0:len(shellshape) - 1])
				translate(shellshape[i])
					cylinder(h, r, r);
}

translate([0, 0, shellh]) plate();
shell();
