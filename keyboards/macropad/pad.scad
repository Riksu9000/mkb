include <../../lib/switch.scad>
include <../../lib/screwpost.scad>

deckmode = 0;  // [0:Disabled, 1:Enabled]

// Only in deckmode
holder_angle = 30;

angle = deckmode ? holder_angle : 0;

width = 5;
height = 3;

// Larger values can be used for aesthetic reasons
wall_thickness = 1.75;

$fn = 24; // [8:8.Draft, 24:24.Proto, 72:72.Export]

/* [Hidden] */

bottom_thickness = 1;
wallh = 7;

// Extra clearance between keycaps and walls
keycap_clearance = 0.25;

// Thickness of shell is wt, while minimum thickness of walls around switches are wall_thickness
wt = max((deckmode ? 5 : 1.75) + keycap_clearance, wall_thickness + keycap_clearance);

rscrew = 1.5;
rtop   = 3;

// Clearance for processor and handwiring
promicroclearance = 4;
shellh = 9 - plate_thickness + promicroclearance;

r_axle = 5;

screwpos = [
	[key_space, key_space],
	[key_space, (height - 1) * key_space],
	[(width - 1) * key_space, (height - 1) * key_space],
	[(width - 1) * key_space, key_space],
];

// For deckmode
pegpos = [
	[-wt, key_space * 0.5],
	[-wt, (height - 0.5) * key_space],
	[(width * key_space) + 1.75, key_space * 0.5],
	[(width * key_space) + 1.75, (height - 0.5) * key_space],
];


module tear(h, r)
{
	rotate([-90, 0]) cylinder(h, r, r);
	rotate([0, -45]) cube([r, h, r]);
}

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

		if(deckmode)
			for(i = [0:len(pegpos) - 1])
				translate(pegpos[i])
					rotate(-90)
						tear(wt - 1.75, r_axle);
	}
}


module shell()
{
	center = (width / 2) * key_space;
	difference()
	{
		translate([0, 0, -bottom_thickness]) shape(shellh + bottom_thickness);
		cube([key_space * width, key_space * height, shellh]);

		if(deckmode)
			translate([0, 0, shellh])
				for(i = [0:len(pegpos) - 1])
					translate(pegpos[i])
						rotate([0, 90])
							cylinder(wt - 1.75, r_axle, r_axle);

		// Micro USB-port
		translate([center - 4, height * key_space, 0.75]) cube([8, wt, 4]);
		translate([center - 8, (height * key_space) + 1, 0.75 - 4]) cube([16, wt, 12]);
	}

	// Pro micro holder
	translate([center - 11.5, (height * key_space) - 34]) cube([2, 34, 1]);
	translate([center + 9.5, (height * key_space) - 34]) cube([2, 34, 1]);

	for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
		screwpost();
}

module stand()
{
	dist = key_space * (height - 1);
	thickness = 3;
	r = r_axle - 0.3;
	height = sqrt((shellh + bottom_thickness) * (shellh + bottom_thickness) + ((key_space / 2) + wt) * ((key_space / 2) + wt)) + 1;

	//https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/undersized_circular_objects
	module cylinder_outer(height,radius,fn){
	   fudge = 1/cos(180/fn);
	   cylinder(h=height,r=radius*fudge,$fn=fn);}

	module peg(h = thickness, r = r)
	{
		intersection()
		{
			rotate([0, 90]) cylinder(h, r, r);
			hull()
			{
				rotate([0, -90]) cylinder(1, r, r);
				translate([h, 0, h]) rotate([0, 90]) cylinder(1, r, r);
			}
		}
	}

	module plate()
	{
		hull()
		{
			rotate([0, 90]) cylinder(thickness, r, r);
			translate([0, dist]) rotate([0, 90]) cylinder(thickness, r, r);
			rotate([angle, 0]) translate([0, dist]) rotate([0, 90]) cylinder(thickness, r, r);
			translate([0, dist + height, - height + r]) rotate([90, 180 / 8, 90]) cylinder_outer(thickness, r, 8);
			translate([0, -height, -height + r]) rotate([90, 180 / 8, 90]) cylinder_outer(thickness, r, 8);
		}
	}

	// Left holder
	translate([-wt, key_space * 0.5, shellh])
	{
		peg();
		rotate([angle, 0]) translate([0, dist]) rotate([-angle, 0]) peg();
		translate([-thickness, 0]) plate();
	}

	// Right holder
	translate([(width * key_space) + wt, key_space * 0.5, shellh])
	{
		rotate(180) peg();
		rotate([angle, 0]) translate([0, dist]) rotate([angle, 0, 180]) peg();
		plate();
	}

	// Connecting rods
	translate([-wt, (key_space * 0.5) + dist + height, -height + shellh + r]) rotate([90, 180 / 8, 90]) cylinder_outer((width * key_space) + (2 * wt), r, 8);
	translate([-wt, (key_space * 0.5) - height, -height + shellh + r]) rotate([90, 180 / 8, 90]) cylinder_outer((width * key_space) + (2 * wt), r, 8);
}

module shape(h, r = wt)
{
	shellshape = [
		[0, 0],
		[0, height * key_space],
		[width * key_space, height * key_space],
		[width * key_space, 0],
	];

	hull()
		for(i = [0:len(shellshape) - 1])
			translate(shellshape[i])
				cylinder(h, r, r);
}

translate([0, key_space * 0.5, shellh]) rotate([angle, 0]) translate([0, -key_space * 0.5, -shellh])
{
	translate([0, 0, shellh]) plate();
	shell();
}
if(deckmode) stand();

//stand();
//translate([0, 0, shellh]) plate();
//shell();
