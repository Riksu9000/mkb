include <../../lib/switch.scad>

plate_thickness = 3;
key_space = 19.05; // Distance between switches is 5.05mm

// Regular 60% layout
r1 = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2];
r2 = [1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5];
r3 = [1.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.25];
r4 = [2.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.75];
r5 = [1.25, 1.25, 1.25, 6.25, 1.25, 1.25, 1.25, 1.25];
rows = [r5, r4, r3, r2, r1];

function add(v, p, i = 0, r = 0) = i < p ? add(v, p, i + 1, r + v[i]) : r;

difference()
{
	cube([key_space * 15, key_space * 5, plate_thickness]);
	for(j = [0:len(rows) - 1], i = [0:len(rows[j]) - 1])
		translate([(add(rows[j], i) * key_space) + (((rows[j][i] - 1) / 2) * key_space), j * key_space]) switch(plate_thickness);
}

