// levelwedge.scad
$fs = 0.5;
$fa = 2;
// A printable instrument to level a printbed.
// Author: Tony Ivanov <telamohn@gmail.com>


//------------- Configuration

// The ratio between the two radii decides the accuracy of
// the tool. R1 goes under the nozzle , and R2 is the indicator.
R1 = 10;
R2 = 40;
// Angle of the indicator.
A = 165; 
// General part thickness ( adjust if they're too flimsy ) 
TH = 4;
// The maximum angle the dial will reach e.g.
// this value defines the size of your dial/gradient.
DialA = 41;

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
      translate([-lpad,0,TH/2+0.5]) scale([1,1,-1]) cube([R2+lpad+0.5,TH,bH]);
      // Screw Pad
      translate([0,-1.5,0]) rotate([-90,0,0]) cylinder(r=2.4,h=1.5);
      // dial
      dialW=TH*2.5;
      m=1;
      rotate([-90]){
        difference(){
          difference(){
            cylinder(r=R2,h=TH);
            dstep = (R2*2*PI) / (R1*2*PI);
            depthTweak=0.2;
            for(i=[0:dstep:DialA]){
              rotate([0,0,-i]){
                union(){
                  inset = i % (dstep*2) == 0 ? 2 : 0;
                  //front groove
                  translate([R2-TH-inset,0,-m-depthTweak]) rotate([45,0,0]) cube([TH+4,m,m]);
                  // back groove
                  translate([R2-TH-inset,0,TH-m*0.5+depthTweak]) rotate([45,0,0]) cube([TH+4,m,m]);
                  // rim groove
                  translate([R2-0.5*m+depthTweak,0,-0.5]) rotate([0,0,-45]) cube([m,m,TH+1]);
                }
              }
            }
          }
          translate([0,0,-0.5]){
            // Draw a 360 degree dial
            cylinder(r=R2-dialW,h=TH+1);
            // Subtract the 180 degrees below Z
            translate([-R2,0,0]) cube([R2*2,R2,TH+1]);
            // Subtract remaining part to leave DialA 
            rotate([0,0,180-DialA]) translate([-R2,0,0]) cube([R2*2,R2,TH+1]);
          }
        }
      }
    }
      // Text
      dstep = (R2*2*PI) / (R1*2*PI);
      maxD = DialA / dstep;
      for(i=[dstep:dstep*2:DialA]){
        mm=  round(i/dstep - maxD*0.5);
        rotate([0,-i,0])
          translate([R2-bH,TH,0]) rotate([90,0,0]) 
           scale([-1,1,1]) text(str(mm),size=3,valign="center",halign="center");
      }
    rotate([-90,0,0]) translate([0,0,TH]) BoltM2(l=20,inset=false);
  }
}

//-------------- Assembly
translate([0,-TH-1,0]) IndicatorArm();
BasePlate();

