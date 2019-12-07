/* Requires global cols vector of vectors. Each first variable in each vector
 * of vectors is the vertical stagger, and the second variable is the number of
 * keys vertically. The number of columns or rows is not limited.
 * Example below
 *
 * cols = [
 *     [vertical_offset, num_of_keys],
 *     [offset_of_second_col, nkeys_of_sec_col],
 * ];
 *
 * 	*/

include <switch.scad>

module dsacaps(col = "#222", z = plate_thickness)
{
	color(col)
		for(x = [0:len(cols) - 1], y = [0:cols[x][1] - 1])
			translate([key_space * x, (key_space * y) + cols[x][0], z + 7])
				dsacap(unit = 1.0);
}

module dsacap(unit = 1.0)
{
	hull()
	{
		translate([key_space / 2, key_space / 2]) rotate(45) cylinder(7.5, 18.25/sqrt(2), 12/sqrt(2), $fn = 4);
		if(unit > 1.0) translate([(unit - 0.5) * key_space, key_space / 2]) rotate(45) cylinder(7.5, 18.25/sqrt(2), 12/sqrt(2), $fn = 4);
	}
}

