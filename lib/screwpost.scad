/* This module accepts global variables and function parameters */
module screwpost(h = shellh, rtop = rtop, rscrew = rscrew)
{
	difference()
	{
		union()
		{
			translate([0, 0, h - 2]) cylinder(2, rtop, rtop);
			cylinder(h - 2, rtop + wall_thickness, rtop);
		}
		cylinder(h, rscrew, rscrew);
	}
}

