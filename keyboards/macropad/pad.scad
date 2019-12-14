include <../../lib/switch.scad>
include <../../lib/screwpost.scad>

deckmode = 0;  // [0:Disabled, 1:Enabled]

holder_angle = 30;

angle = deckmode ? holder_angle : 0;

width = 5;
height = 3;

wall_thickness = deckmode ? 5 : 2;

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

r_axle = 5;

screwpos = [
	[key_space, key_space],
	[key_space, (height - 1) * key_space],
	[(width - 1) * key_space, (height - 1) * key_space],
	[(width - 1) * key_space, key_space],
];

module tear(h, r)
{
	rotate([-90, 0]) cylinder(h, r, r);
	rotate([0, -45]) cube([r, h, r]);
}

module cylinder_outer(height,radius,fn){
   fudge = 1/cos(180/fn);
   cylinder(h=height,r=radius*fudge,$fn=fn);}

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
		{
			translate([-wt, key_space * 0.5]) rotate([0, 90]) cylinder(3, r_axle, r_axle);
			translate([(width * key_space) + wt, key_space * 0.5]) rotate([0, -90]) cylinder(3, r_axle, r_axle);
			translate([-wt, (height - 0.5) * key_space]) rotate([0, 90]) cylinder(3, r_axle, r_axle);
			translate([(width * key_space) + wt, (height - 0.5) * key_space]) rotate([0, -90]) cylinder(3, r_axle, r_axle);
		}
	}
}


module shell()
{
	difference()
	{
		translate([0, 0, -bottom_thickness]) shape(shellh + bottom_thickness);
		shape(shellh, 0);

		if(deckmode)
		{
			translate([-wt, key_space * 0.5, shellh]) rotate([0, 90]) cylinder(3, r_axle, r_axle);
			translate([(width * key_space) + wt, key_space * 0.5, shellh]) rotate([0, -90]) cylinder(3, r_axle, r_axle);
			translate([-wt, (height - 0.5) * key_space, shellh]) rotate([0, 90]) cylinder(3, r_axle, r_axle);
			translate([(width * key_space) + wt, (height - 0.5) * key_space, shellh]) rotate([0, -90]) cylinder(3, r_axle, r_axle);
		}

		// Micro USB-port
		translate([((width / 2) * key_space) - 4, height * key_space, 0.75]) cube([8, wt, 4]);
		translate([((width / 2) * key_space) - 8, (height * key_space) + 1, 0.75 - 4]) cube([16, wt, 12]);
	}

	// Pro micro holder
	translate([((width / 2) * key_space) - 11.5, (height * key_space) - 34]) cube([2, 34, 1]);
	translate([((width / 2) * key_space) + 9.5, (height * key_space) - 34]) cube([2, 34, 1]);

	for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
		screwpost();
}

module stand()
{

	dist = key_space * (height - 1);
	thickness = 3;
	r = r_axle - 0.3;
	height = sqrt((shellh + bottom_thickness) * (shellh + bottom_thickness) + ((key_space / 2) + wt) * ((key_space / 2) + wt)) + 1;

	module peg(h = thickness, r = r) rotate([0, 90]) cylinder(h, r, r);

	module plate()
	{
		hull()
		{
			peg();
			translate([0, dist]) peg();
			rotate([angle, 0]) translate([0, dist]) peg();
			translate([0, dist + height, - height + r]) rotate([90, 180 / 8, 90]) cylinder_outer(thickness, r, 8);
			translate([0, -height, -height + r]) rotate([90, 180 / 8, 90]) cylinder_outer(thickness, r, 8);
		}
	}

	// Left holder
	translate([-wt, key_space * 0.5, shellh])
	{
		peg();
		rotate([angle, 0]) translate([0, dist]) peg();
		translate([-thickness, 0]) plate();
	}

	// Right holder
	translate([(width * key_space) + wt - thickness, key_space * 0.5, shellh])
	{
		peg();
		rotate([angle, 0]) translate([0, dist]) peg();
		translate([thickness, 0]) plate();
	}

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

	if(r == 0)
		cube([key_space * width, key_space * height, plate_thickness + h]);
	else
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
