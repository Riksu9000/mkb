include <../../lib/switch.scad>
include <../../lib/screwpost.scad>
include <../../lib/dsacaps.scad>

deckmode = false;

// Only in deckmode
holder_angle = 30;
angle = deckmode ? holder_angle : 0;

width = 5; // [3:20]
height = 3; // [3:20]

// Larger values can be used for aesthetic reasons
wall_thickness = 1.75;

hbevel = 0; // [0:10]

wallh = 7; // [0:15]

// Experimental option when wallh=0 to make the device 3.4mm smaller...
compact = false;

/* [Preview] */

previewcaps = false;

fn = 24; // [8:8.Draft, 24:24.Proto, 72:72.Export]
$fn = $preview ? fn : 72;

/* [Hidden] */

p = $preview ? 0.1 : 0;

// Only allow shrinking when requirements are met
shrink = (wallh == 0) && compact ? (key_space - 15.6) / 2 : 0;

MAXBEVEL = 10;

bottom_thickness = 1;

// Extra clearance between keycaps and walls
key_clearance = 0.25;

// Thickness of shell is wt, while minimum thickness of walls around switches are wall_thickness
wt = max((deckmode ? 5 : 1.75) + key_clearance, wall_thickness + key_clearance);

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
		if(wallh > 0)
			translate([-key_clearance, -key_clearance, plate_thickness])
				cube([(key_space * width) + (key_clearance * 2), (key_space * height) + (key_clearance * 2), wallh + p]);

		for(x = [0:width - 1], y = [0:height - 1])
			translate([key_space * x, key_space * y, -p])
				switch(plate_thickness + p+p);
	
		for(i = [0:len(screwpos) - 1]) translate(screwpos[i])
			cylinder(plate_thickness + p, rscrew, rscrew);

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
		union()
		{
			translate([0, 0, -bottom_thickness]) shape(shellh + bottom_thickness, wt, hbevel);
			translate([center - 11.5, (height * key_space) - MAXBEVEL - shrink, -bottom_thickness]) cube([23, wt + MAXBEVEL, MAXBEVEL + bottom_thickness]);
		}
		shape(shellh + bottom_thickness, 0, hbevel);

		if(deckmode)
			translate([0, 0, shellh])
				for(i = [0:len(pegpos) - 1])
					translate(pegpos[i])
						rotate([0, 90])
							cylinder(wt - 1.75, r_axle, r_axle);

		// Micro USB-port
		translate([center - 4, (height * key_space) - shrink - p, 1.75])
			cube([8, wt + 1, 3]);
		translate([center - 8, (height * key_space) + 2 - shrink, 0.75 - 4])
			cube([16, wt, 12]);

		// Flatten when using hbevel
		translate([center - 9.5, (height * key_space) - shrink]) rotate(-90) cube([MAXBEVEL, 19, MAXBEVEL]);

		translate([(width / 2) * key_space, hbevel + shrink, -0.2])
			linear_extrude(0.2 + p, convexity = 10)
				text("github.com/Riksu9000/mkb", halign="center", valign="bottom", size=min(width - ((hbevel * 2) / (width * key_space)), 6));
	}

	difference()
	{
		for(i = [0:len(screwpos) - 1])
			translate(screwpos[i])
				screwpost();
		hull()
		{
			translate([center - 9.5, (height * key_space) - 34]) cube([19, 34, 1]);
			translate([center - 9.5 + promicroclearance, (height * key_space) - 34, promicroclearance]) cube([19 - (promicroclearance * 2), 34, 1]);
		}
	}

	// Pro micro holder
	translate([center - 11.25, (height * key_space) - 34])
		cube([2, 34, 1]);
	translate([center + 9.25, (height * key_space) - 34])
		cube([2, 34, 1]);
}

module stand()
{
	dist = key_space * (height - 1);
	thickness = 3;
	peg_depth = 2;
	r = r_axle - 0.15;
	height = sqrt((shellh + bottom_thickness) * (shellh + bottom_thickness) + ((key_space / 2) + wt) * ((key_space / 2) + wt)) + 1;

	//https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/undersized_circular_objects
	module cylinder_outer(h, r, fn)
	{
		fudge = 1/cos(180/fn);
		intersection()
		{
			translate([0, -r]) cube([h, r * 2, r]);
			rotate([90, 180 / 8, 90]) cylinder(h,r=r*fudge,$fn=fn);
		}
	}

	module peg(h = peg_depth, r = r)
	{
		intersection()
		{
			rotate([0, 90]) cylinder(h, r, r);
			hull()
			{
				rotate([0, -90]) cylinder(1, r, r);
				translate([h, 0, h]) rotate([0, -90]) cylinder(1, r, r);
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
			translate([0, dist + height, - height]) cylinder_outer(thickness, r, 8);
			translate([0, -height, -height]) cylinder_outer(thickness, r, 8);
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
	translate([-wt, (key_space * 0.5) + dist + height, -height + shellh]) cylinder_outer((width * key_space) + (2 * wt), r, 8);
	translate([-wt, (key_space * 0.5) - height, -height + shellh]) cylinder_outer((width * key_space) + (2 * wt), r, 8);
}

module shape(h, r = wt, hbevel = 0)
{
	shellshape = [
		[shrink, shrink],
		[shrink, (height * key_space) - shrink],
		[(width * key_space) - shrink, (height * key_space) - shrink],
		[(width * key_space) - shrink, shrink],
	];

	hull()
	{
		if(r == 0)
		{
			translate([hbevel + shrink, hbevel + shrink])
				cube([(width * key_space) - (hbevel * 2) - (shrink * 2), (height * key_space) - (hbevel * 2) - (shrink * 2), hbevel]);
			translate([shrink, shrink, hbevel])
				cube([(width * key_space) - (shrink * 2), (height * key_space) - (shrink * 2), h - hbevel]);
		}
		else
		{
			for(i = [0:len(shellshape) - 1])
			{
				translate([shellshape[i][0], shellshape[i][1], hbevel])
					cylinder(h - hbevel, r, r);
				translate([shellshape[i][0] + (shellshape[i][0] == shrink ? hbevel : -hbevel), shellshape[i][1] + (shellshape[i][1] == shrink ? hbevel : -hbevel)])
					cylinder(hbevel, r, r);
			}
		}
	}
}

translate([0, key_space * 0.5, shellh])
	rotate([angle, 0])
		translate([0, -key_space * 0.5, -shellh])
		{
			translate([0, 0, shellh]) plate();
			shell();
			if(previewcaps)
				for(x = [0:width - 1], y = [0:height - 1])
					translate([key_space * x, key_space * y, shellh + plate_thickness + 7])
						dsacap();
		}

if(deckmode)
	stand();

