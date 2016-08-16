// 3D-printable quadcopter
// Original author: Carlos Garcia Saura (@carlosgs)
// License: CC-BY-SA 4.0 (Attribution-ShareAlike 4.0 International, http://creativecommons.org/licenses/by-sa/4.0/)
// Designed with http://www.openscad.org/

// Uncomment to increase global shape resolution
//$fa = 5; // Minimum angle for fragments [degrees]
//$fs = 1; // Minimum fragment size [mm]

N_arms = 4;
arm_length = 120;

module propeller(holes=false) { // the position is relative to each motor's axis
    if(holes) {
        // x4 screw holes for each motor
        for(i=[1:4]) rotate([0,0,360*i/4+45]) {
            hull() for(j=[7.5,10]) translate([j,0,0]) cylinder(r=3.5/2, h=40, center=true);
            hull() for(j=[7.5,10]) translate([j,0,-7]) rotate([180,0,0]) cylinder(r=6.5/2, h=20);
        }
        // hole for the motor
        cylinder(r=31/2, h=15);
    } else {
        cylinder(r=27/2, h=15); // motor
        translate([0,0,15]) cylinder(r=14/2, h=19); // shaft
        translate([0,0,15+3]) cylinder(r=155/2, h=10); // propeller
    }
}

module esc_motor_driver(holes=false) { // the position is relative to each motor's axis
    rotate([0,0,180]) translate([30,0,0]) if(holes) {
        translate([-5,-10,-11]) cube([45,20,11]); // hole for ESC
        translate([-20,-4.5,-5]) {// hole for ESC wires
            cube([50,9,5]);
            cube([10,9,15]);
        }
        // holes for the zip-tie on each arm
        translate([-9,8,0]) cube([5,2.5,100],center=true);
        translate([-9,-8,0]) cube([5,2.5,100],center=true);
    } else {
        translate([6,-9,-10]) cube([34,18,8]);
    }
}

module arm(angle=0) {
    rotate([0,0,angle]) {
        translate([arm_length,0,0]) {
            difference() {
                translate([0,0,-5]) hull() {
                    cylinder(r=29/2, h=10, center=true);
                    translate([-arm_length,0,0]) sphere(r=50/2, h=10, center=true);
                }
                propeller(holes=true);
                esc_motor_driver(holes=true);
            }
            %propeller();
            %esc_motor_driver();
        }
    }
}

module all_arms() {
    for(i=[1:N_arms]) arm(angle=45+i*360/N_arms);
}

middle_sphere_diameter=90;
middle_length=110;
middle_side_len=35;
middle_corner_radius=5;

module quad_body_noHoles() {
    all_arms();
    sphere(r=middle_sphere_diameter/2);
    // battery support
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

module quad_body(cut=0) {
    difference() {
        quad_body_noHoles();
        additional_holes();
        vitamins(holes=true);
        if(cut==1) translate([0,0,-0.2]) cylinder(r=500/2,h=100);
        if(cut==2) translate([0,0,0.2]) rotate([180,0,0]) cylinder(r=500/2,h=100);
    }
    %vitamins();
}

// Uncomment the option that you wish to render
//quad_body(); // full quadcopter (assembled)
quad_body(cut=1); // lower half
//rotate([180,0,0]) quad_body(cut=1); // lower half (flipped for 3D printing)
//quad_body(cut=2); // upper half




















module additional_holes() {
    difference() {
        union() {
            sphere(r=middle_sphere_diameter/2-5);
            for(i=[1:N_arms]) rotate([0,0,45+i*360/N_arms]) hull() {
                sphere(r=40/2);
                translate([arm_length/1.5,0,0]) sphere(r=5/2);
            }
        }
        // flush bottom
        translate([-100/2,-100/2,-50]) cube([100,100,50]);
    }
}

module vitamins(holes=false) {
    translate([-3,0,2]) arduino(holes);
    translate([0,0,-middle_sphere_diameter/2+middle_side_len/2+middle_corner_radius]) battery(holes);

    translate([-70,0,-20]) rotate([0,0,180]) camera(holes);

    translate([0,0,36]) rotate([0,0,-90]) gps(holes);
    translate([0,0,33]) IMU(holes);
    translate([53,0,14]) rotate([0,0,0]) video_tx(holes);
    translate([14,17,36]) rotate([0,0,180]) rotate([0,90,0]) radio_rx_without_case(holes);

    translate([0,-19,-19]) rotate([0,180,0]) ultrasound(holes);
    translate([0,19,-19]) rotate([0,180,0]) rotate([0,0,180]) ultrasound(holes);
}

// From: https://github.com/Obijuan/printbot_part_library/tree/master/sensors/ultrasound
module ultrasound(holes=false, slot=19) {
    translate([0,-4.5,0]) rotate([90,0,0])
    if(holes) {
        difference() { // flush hole top
            union() {
                translate([14,0,0]) { // hole for emmiter
                    hull() {
                        cylinder(r=17/2,h=14);
                        translate([0,-slot-7,0]) cylinder(r=17/2,h=14);
                    }
                    translate([0,0,13.5]) cylinder(r1=17/2,r2=70/2,h=50);
                }
                translate([-14,0,0]) { // hole for receiver
                    hull() {
                        cylinder(r=17/2,h=14);
                        translate([0,-slot-7,0]) cylinder(r=17/2,h=14);
                    }
                    translate([0,0,13.5]) cylinder(r1=17/2,r2=70/2,h=50);
                }
                hull() { // hole for the PCB
                    translate([-18,0,-3]) cylinder(r=20/2,h=5);
                    translate([18,0,-3]) cylinder(r=20/2,h=5);
                    translate([-18,-slot,-3]) cylinder(r=20/2,h=5);
                    translate([18,-slot,-3]) cylinder(r=20/2,h=5);
                }
            }
            translate([-100/2,-100-slot,-100/2]) cube([100,100,100]);
        }
    } else import("libs/BAT-ultrasonic.stl");
}

// From: https://github.com/bq/zum/tree/master/zum-bt328/stl
module arduino_itself() {
    translate([34.5,26.5,1.6])
        rotate([0,0,180])
            import("libs/zum_bt_328.stl");
}

module arduino(holes=false, hole_len=4) {
    if(holes) {
        // main hole for the board
        translate([0,0,-2]) linear_extrude(height=4) offset(r=1) projection() hull() arduino_itself();
        difference() {
            minkowski() {
                hull() arduino_itself();
                sphere(r=1); // add 1mm offset around the shape of the arduino board
            }
            // flush bottom
            translate([-100/2,-100/2,-50]) cube([100,100,50]);
        }
        
        // screws
        screw_diam = 3;
        translate([19.25,-24.25,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([20.5,24,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([-31.5,19,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([-31.5,-9,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        for(i=[-1,1]) for(j=[-1,1]) translate([10*i,10*j,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
    } else arduino_itself();
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
