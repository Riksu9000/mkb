// This module accepts global variables and function parameters
module screwpost(h = shellh, rtop = rtop, rscrew = rscrew)
{
	difference()
	{
		union()
		{
			translate([0, 0, h - 2]) cylinder(2, rtop, rtop);
			cylinder(h - 2, rtop + wall_thickness, rtop);
		}
		cylinder(h + 0.01, rscrew, rscrew);
	}
}

// This can be used to hollow out the post if necessary
module screwhole(h = shellh, rscrew = rscrew)
{
	cylinder(h, rscrew, rscrew);
}

