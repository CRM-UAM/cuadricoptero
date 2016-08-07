
// Increase the resolution of default shapes
$fa = 5; // Minimum angle for fragments [degrees]
$fs = 0.5; // Minimum fragment size [mm]

module propeller() {
    color("darkgray") cylinder(r=27/2, h=15);
    color("darkgray") translate([0,0,15]) cylinder(r=14/2, h=19);
    translate([0,0,15+3]) cylinder(r=155/2, h=10);
}

module arm(angle=0, length=120) {
    rotate([0,0,angle]) {
        translate([length,0,0]) %propeller();
        translate([0,0,-5]) hull() {
            translate([length,0,0]) cylinder(r=27/2, h=10, center=true);
            sphere(r=50/2, h=10, center=true);
        }
    }
}

module all_arms(N=4) {
    for (i = [1:N]) arm(angle=45+i*360/N);
}

module quad_body() {
    union() {
        all_arms();
        sphere(r=90/2, h=10, center=true);
    }
}

%quad_body();
translate([0,0,-8]) arduino();
translate([10,0,-40]) battery();

translate([-60,0,-30]) rotate([0,0,180]) camera();

translate([0,0,36]) rotate([0,0,-90]) gps();
translate([0,0,33]) IMU();
translate([-10,-14,12]) video_tx();
translate([-18,20,12]) rotate([0,0,180]) radio_rx();



// From: https://github.com/Obijuan/printbot_part_library/tree/master/sensors/ultrasound
module ultrasound() {
    color("darkgray")
    translate([0,ultrasound_posY,0])
        translate([0,-4.5,14]) rotate([90,0,0]) import("libs/BAT-ultrasonic.stl");
}

// From: https://github.com/bq/zum/tree/master/zum-bt328/stl
module arduino(holes=false, hole_len=10) {
    if(holes) {
        translate([19.25,-24.25,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([20.5,24,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([-31.5,19,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        translate([-31.5,-9,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
        for(i=[-1,1]) for(j=[-1,1]) translate([10*i,10*j,0]) cylinder(r=screw_diam/2, h=hole_len*5, center=true);
    } else translate([34.5,26.5,1.6]) rotate([0,0,180]) import("libs/zum_bt_328.stl");
}

module battery() {
    cube([106,37,35],center=true);
    translate([106/2,0,35/2]) cube([15,32,15],center=true);
}

module radio_rx() {
    translate([-43+4,-15/4,-4]) {
        translate([-10,9,6]) rotate([0,90,0]) cylinder(r=10/2,h=10);
        cube([43,15,23]);
        translate([43-4,15/4,23]) cylinder(r=2/2,h=28);
        translate([43,15/4,4]) rotate([0,90,0]) cylinder(r=2/2,h=28);
    }
}

module video_tx() {
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

module gps() {
    translate([-0.5-25/2,-26/2,0]) {
        cube([30,26,3]);
        translate([24,4,-2]) cube([10,12,4]);
        translate([0.5,0.5,3]) cube([25,25,3]);
    }
}

module IMU() {
    translate([-20/2,-15.5/2,-10]) {
        cube([10,3,12]);
        translate([0,0,1]) cube([20,15.5,2]); // MPU6050 gyro+acc
        translate([0,0,5]) cube([13,15,2]); // HMC5883L magnetometer
        translate([0,0,9]) cube([11,13,2]); // BMP180 barometer
    }
}

module camera() {
    cube([15,40,38],center=true);
    rotate([0,90,0]) cylinder(r=9,h=20);
}