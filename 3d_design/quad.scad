
// Increase the resolution of default shapes
//$fa = 5; // Minimum angle for fragments [degrees]
//$fs = 0.5; // Minimum fragment size [mm]
$fa = 15; // Minimum angle for fragments [degrees]
$fs = 2; // Minimum fragment size [mm]

module propeller(holes=false) { // the position is relative to each motor's axis
    if(holes) {
        // x4 screw holes for each motor
        for(i=[1:4]) rotate([0,0,360*i/4+45]) {
            hull() for(j=[7.5,10]) translate([j,0,0]) cylinder(r=3.5/2, h=40, center=true);
            hull() for(j=[7.5,10]) translate([j,0,-7]) rotate([180,0,0]) cylinder(r=5/2, h=20);
        }
        // hole for the motor
        cylinder(r=29/2, h=15);
    } else {
        cylinder(r=27/2, h=15); // motor
        translate([0,0,15]) cylinder(r=14/2, h=19); // shaft
        *translate([0,0,15+3]) cylinder(r=155/2, h=10); // propeller
    }
}

module esc_motor_driver(holes=false) { // the position is relative to each motor's axis
    rotate([0,0,180]) translate([30,0,0]) if(holes) {
        translate([0,-10,-11]) cube([45,20,11]); // hole for ESC
        translate([-20,-4.5,-5]) {// hole for ESC wires
            cube([50,9,5]);
            cube([10,9,15]);
        }
    } else {
        translate([6,-9,-10]) cube([34,18,8]);
    }
}

module arm(angle=0, length=120) {
    rotate([0,0,angle]) {
        translate([length,0,0]) {
            difference() {
                translate([0,0,-5]) hull() {
                    cylinder(r=27/2, h=10, center=true);
                    translate([-length,0,0]) sphere(r=50/2, h=10, center=true);
                }
                propeller(holes=true);
                esc_motor_driver(holes=true);
            }
            %propeller();
            %esc_motor_driver();
        }
    }
}

module all_arms(N=4) {
    for(i=[1:N]) arm(angle=45+i*360/N);
}

middle_sphere_diameter=90;
middle_length=110;
middle_side_len=35;
middle_corner_radius=5;

module quad_body_noHoles() {
    union() {
        all_arms();
        sphere(r=middle_sphere_diameter/2);
        translate([0,0,-middle_sphere_diameter/2+middle_side_len/2+middle_corner_radius]) {
            hull() {
                translate([middle_length/2,middle_side_len/2,middle_side_len/2]) sphere(r=middle_corner_radius);
                translate([middle_length/2,middle_side_len/2,-middle_side_len/2]) sphere(r=middle_corner_radius);
                translate([middle_length/2,-middle_side_len/2,middle_side_len/2]) sphere(r=middle_corner_radius);
                translate([middle_length/2,-middle_side_len/2,-middle_side_len/2]) sphere(r=middle_corner_radius);
                
                translate([-middle_length/2,middle_side_len/2,middle_side_len/2]) sphere(r=middle_corner_radius);
                translate([-middle_length/2,middle_side_len/2,-middle_side_len/2]) sphere(r=middle_corner_radius);
                translate([-middle_length/2,-middle_side_len/2,middle_side_len/2]) sphere(r=middle_corner_radius);
                translate([-middle_length/2,-middle_side_len/2,-middle_side_len/2]) sphere(r=middle_corner_radius);
            }
        }
    }
}

module quad_body(cut=0) {
    difference() {
        quad_body_noHoles();
        vitamins(holes=true);
        if(cut==1) translate([-1000/2,-1000/2,-0.1]) cube([1000,1000,1000]);
        if(cut==2) translate([-1000/2,-1000/2,-1000+0.1]) cube([1000,1000,1000]);
    }
    %vitamins();
}

//!rotate([180,0,0]) quad_body_lowerHalf(); // uncomment to select print mode
quad_body(cut=1);

module vitamins(holes=false) {
    translate([-3,0,2]) arduino(holes);
    translate([0,0,-middle_sphere_diameter/2+middle_side_len/2+middle_corner_radius]) battery(holes);

    translate([-70,0,-20]) rotate([0,0,180]) camera(holes);

    translate([0,0,36]) rotate([0,0,-90]) gps(holes);
    translate([0,0,33]) IMU(holes);
    translate([53,0,14]) rotate([0,0,0]) video_tx(holes);
    translate([14,17,36]) rotate([0,0,180]) rotate([0,90,0]) radio_rx_without_case(holes);

    translate([0,-20,-20]) rotate([0,180,0]) ultrasound(holes);
    translate([0,20,-20]) rotate([0,180,0]) rotate([0,0,180]) ultrasound(holes);
}

// From: https://github.com/Obijuan/printbot_part_library/tree/master/sensors/ultrasound
module ultrasound(holes=false) {
    if(holes) {
        
    } else {
        translate([0,-4.5,0])
            rotate([90,0,0]) import("libs/BAT-ultrasonic.stl");
    }
}

// From: https://github.com/bq/zum/tree/master/zum-bt328/stl
module arduino(holes=false, hole_len=4) {
    if(holes) {
        screw_diam = 3;
        translate([19.25,-24.25,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([20.5,24,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([-31.5,19,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([-31.5,-9,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        for(i=[-1,1]) for(j=[-1,1]) translate([10*i,10*j,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
    } else translate([34.5,26.5,1.6]) rotate([0,0,180]) import("libs/zum_bt_328.stl");
}

module battery(holes=false) {
    if(holes) {
        // pocket to allow sliding-in the battery
        translate([106/2,0,35/2]) cube([15,32,15],center=true);
        translate([30/2-6.9+3,0,0]) cube([106+30,40,36],center=true);
        // hole for velcro strap
        translate([106/2,0,35/2]) cube([4,25,200],center=true);
    } else {
        cube([106,37,35],center=true);
    }
}

//module radio_rx() { // unused
//    translate([-4,-10,-4.5]) %cube([43,14,23]);
//    radio_rx_without_case();
//}

module radio_rx_without_case(holes=false) {
    if(holes) {
        
    } else {
        translate([-2,-1,-2.5]) {
            cube([30,3,17.5]);
            translate([30-7,-5,0]) cube([7,5,2]);
        }
        translate([0,0,17.5-2.5]) cylinder(r=1.5/2,h=29);
        translate([-2,0,0]) rotate([0,-90,0]) cylinder(r=1.5/2,h=30);
    }
}

module video_tx(holes=false) {
    if(holes) {
        
    } else {
        translate([-30-21+3,-14,0]) {
            translate([-5,10,3]) cube([5,10,5]);
            cube([30,21,9]);
            translate([30,14,9/2]) {
                rotate([0,90,0]) cylinder(r=10/2,h=21);
                translate([21-3,0,0]) {
                    cylinder(r=4/2,h=51);
                    translate([0,0,51]) cylinder(r1=40/2,r2=30/2,h=18);
                }
            }
        }
    }
}

module gps(holes=false) {
    if(holes) {
        
    } else {
        translate([-0.5-25/2,-26/2,0]) {
            cube([30,26,3]);
            translate([24,4,-2]) cube([10,12,4]);
            translate([0.5,0.5,3]) cube([25,25,3]);
        }
    }
}

module IMU(holes=false) {
    if(holes) {
        
    } else {
        translate([-20/2,-15.5/2,-10]) {
            cube([10,3,12]);
            translate([0,0,1]) cube([11,13,2]); // BMP180 barometer
            translate([0,0,5]) cube([13,15,2]); // HMC5883L magnetometer
            translate([0,0,9]) cube([20,15.5,2]); // MPU6050 gyro+acc
        }
    }
}

module camera(holes=false) {
    if(holes) {
        
    } else {
        cube([15,40,38],center=true);
        rotate([0,90,0]) cylinder(r=9,h=20);
    }
}
