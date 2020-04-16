include <../../lib/switch.scad>
include <../../lib/screwpost.scad>
include <../../lib/dsacaps.scad>

// Larger values can be used for aesthetic reasons
wall_thickness = 1.75;

$fn = 24; // [8:8.Draft, 24:24.Proto, 72:72.Export]

hbevel = 0; // [0:10]

/* [Hidden] */

width = 12;
height = 4;

MAXBEVEL = 10;

bottom_thickness = 1;
wallh = 7;

// Extra clearance between keycaps and walls
key_clearance = 0.25;

// Thickness of shell is wt, while minimum thickness of walls around switches are wall_thickness
wt = wall_thickness + key_clearance;

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

p = $preview ? 0.1 : 0;

bottom_row = 6;
bottom_row_unit = 1.25;

module plate()
{
	bottom_row_offset = ((width * key_space) - (bottom_row * bottom_row_unit * key_space)) / 2;
	difference()
	{
		shape(plate_thickness + wallh);

		// Bottom row space
		translate([-key_clearance + bottom_row_offset, -key_clearance, plate_thickness])
			cube([(key_space * bottom_row * bottom_row_unit) + (key_clearance * 2), (key_space * height) + (key_clearance * 2), wallh + p]);

		// Rest of the rows space
		for(y = [1:height - 1])
			translate([-key_clearance, -key_clearance + y * key_space, plate_thickness])
				cube([(key_space * width) + (key_clearance * 2), key_space + (key_clearance * 2), wallh + p]);

		// Bottom row switches
		for(x = [0:bottom_row - 1])
			translate([bottom_row_offset + (((bottom_row_unit - 1) / 2) * key_space) + (key_space * bottom_row_unit * x), 0, -p])
				switch(plate_thickness + p + p);

		// Rest of the rows switches
		for(x = [0:width - 1], y = [1:height - 1])
			translate([key_space * x, key_space * y, -p])
				switch(plate_thickness + p + p);
	
		// Screwposts
		for(i = [0:len(screwpos) - 1])
			translate(screwpos[i])
				cylinder(plate_thickness + p, rscrew, rscrew);
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
			translate([center - 11.5, (height * key_space) - MAXBEVEL, -bottom_thickness]) cube([23, wt + MAXBEVEL, MAXBEVEL + bottom_thickness]);
		}
		shape(shellh + bottom_thickness, 0, hbevel);

		// Micro USB-port
		translate([center - 4, height * key_space, 0.75]) cube([8, wt, 4]);
		translate([center - 8, (height * key_space) + 1, 0.75 - 4]) cube([16, wt, 12]);

		// Flatten when using hbevel
		translate([center - 9.5, height * key_space]) rotate(-90) cube([MAXBEVEL, 19, MAXBEVEL]);

		translate([(width / 2) * key_space, hbevel, -0.2])
			linear_extrude(0.2 + p)
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
	translate([center - 11.5, (height * key_space) - 34]) cube([2, 34, 1]);
	translate([center + 9.5, (height * key_space) - 34]) cube([2, 34, 1]);
}

module shape(h, r = wt, hbevel = 0)
{
	shellshape = [
		[0, 0],
		[0, height * key_space],
		[width * key_space, height * key_space],
		[width * key_space, 0],
	];

	bottom_rad = (key_space / 2);

	hull()
	{
		if(r == 0)
		{
			translate([hbevel, hbevel + key_space])
				cube([(width * key_space) - (hbevel * 2), ((height - 1) * key_space) - (hbevel * 2), hbevel]);
			translate([0, key_space, hbevel])
				cube([width * key_space, (height - 1) * key_space, h - hbevel]);
		}
		else
		{
			// Top left corner
			translate([hbevel, (height * key_space) - hbevel])
				cylinder(hbevel, r = r);
			translate([0, (height * key_space), hbevel])
				cylinder(h - hbevel, r = r);

			// Top right corner
			translate([(width * key_space) - hbevel, (height * key_space) - hbevel])
				cylinder(h - hbevel, r = r);
			translate([(width * key_space), (height * key_space), hbevel])
				cylinder(h - hbevel, r = r);
		}
		// Bottom left corner
		translate([bottom_rad + hbevel, bottom_rad + hbevel])
			cylinder(hbevel, r = bottom_rad + r);
		translate([bottom_rad, bottom_rad, hbevel])
			cylinder(h - hbevel, bottom_rad + r, bottom_rad + r);

		// Bottom right corner
		translate([(width * key_space) - bottom_rad - hbevel, bottom_rad + hbevel])
			cylinder(hbevel, r = bottom_rad + r);
		translate([(width * key_space) - bottom_rad , bottom_rad, hbevel])
			cylinder(h - hbevel, bottom_rad + r, bottom_rad + r);
	}
}

module keycap_preview()
{
	bottom_row_offset = ((width * key_space) - (bottom_row * bottom_row_unit * key_space)) / 2;
	translate([0, 0, shellh])
	{
		for(x = [0:bottom_row - 1])
			translate([bottom_row_offset + (((bottom_row_unit - 1) / 2) * key_space) + (key_space * bottom_row_unit * x), 0, -p])
				dsacap(unit = bottom_row_unit);
		for(x = [0:width - 1], y = [1:height - 1])
			translate([key_space * x, key_space * y, -p])
				dsacap();
	}
}

plate();
translate([0, 0, -shellh]) shell();

//keycap_preview();
