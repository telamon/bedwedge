// levelwedge.scad

// A printable instrument to level a printbed.
// Author: Tony Ivanov <telamohn@gmail.com>


//------------- Configuration

// The ratio between the two radii decides the accuracy of
// the tool. R1 goes under the nozzle , and R2 is the indicator.
R1 = 10;
R2 = 60;
// Angle of the indicator.
A = 165; 
// General part thickness ( adjust if they're too flimsy ) 
TH = 4;
// The maximum angle the dial will reach e.g.
// this value defines the size of your dial/gradient.
DialA = 35;


//-------------- Modules
use <Metric/M2.scad>;

module IndicatorArm(){
  difference(){
    union(){
      rotate([-90,0,0]) cylinder(r=3,h=TH);
      // R1
      vertThick= 0.75;
      scale([-1,1,1]) translate([0,0,-TH/2]) difference(){
        cube([R1+1,TH,TH*vertThick]);
        // wedge
        // TODO: calculate the rotation relative to R1
        translate([2,-0.5,0]) scale([1,1,-1]) rotate([0,13,0]) cube([R1+1,TH+1,TH*vertThick]);
        // nozzle groove
        translate([R1,TH/2,TH-1.5]) cylinder(r=1,h=3);
      }
      // R2
      l = R2+5;
      rotate([0,A-180,0]) translate([0,0,-TH*vertThick/2]) difference(){
        cube([l+1,TH,TH*vertThick]);
        translate([l-10,-0.5,TH*vertThick]) rotate([0,13,0]) cube([10+2,TH+1,TH*vertThick]);
      }
    }
    rotate([-90,0,0]) translate([0,0,TH]) BoltM2(inset=false);
  }
}

module BasePlate(){
  bH = 7;
  lpad = 3;
  difference(){
    union(){
      translate([-lpad,0,TH/2+0.5]) scale([1,1,-1]) cube([R2+lpad,TH,bH]);
      // Screw Pad
      translate([0,-1.5,0]) rotate([-90,0,0]) cylinder(r=2.4,h=1.5);
      // gradient
      rotate([-90]){
        difference(){
          cylinder(r=R2,h=TH);
          translate([0,0,-0.5]){
            cylinder(r=R2-TH*2,h=TH+1);
            for(i=[0:25:270-DialA]){
              rotate([0,0,i]) cube([R2,R2,TH+1]);
            }
          }
        }
      }
    }
    rotate([-90,0,0]) translate([0,0,TH]) BoltM2(inset=false);
  }
}

//-------------- Assembly
translate([0,TH,0]) IndicatorArm();
BasePlate();

