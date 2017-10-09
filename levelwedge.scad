// levelwedge.scad
$fs = 0.5;
$fa = 2;
// A printable instrument to level a printbed.
// Author: Tony Ivanov <telamohn@gmail.com>


//------------- Configuration

// The ratio between the two radii decides the accuracy of
// the tool. R1 goes under the nozzle , and R2 is the indicator.
R1 = 12;
R2 = 75;
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
        translate([R1,TH/2,TH-1.5+5]) rotate_extrude(angle=360) translate([0,-5]) polygon([[0,0],[0,5],[5,5]]);
      }
      // R2
      l = R2+5;
      rotate([0,A-180,0]) translate([0,0,-TH*vertThick/2]) difference(){
        union(){
          cube([l+1,TH,TH*vertThick]);
          translate([l-4.9,0,0]) cube([5.9,9,3]);
        }
        *translate([l-10,-0.5,TH*vertThick]) rotate([0,-13,0]) cube([10+2,TH+1,TH*vertThick]);
        translate([R2-R2/2-1,-TH,TH/2]) cube([2,TH*4,4]);
      }
    }
    rotate([-90,0,0]) translate([0,0,TH]) BoltM2(inset=false);
  }
}

module BasePlate(bH = 7,lpad = 3,screwPad=0.7,midsect=true){
  difference(){
    union(){
      translate([-lpad,0,TH/2+0.5]) scale([1,1,-1]) cube([R2+lpad+0.5,TH,bH]);
      // Screw Pad
      if(midsect){
        translate([0,-screwPad,0]) rotate([-90,0,0]) cylinder(r=2.4,h=1+screwPad);
      }else{
        translate([0,TH-screwPad,0]) rotate([-90,0,0]) cylinder(r=2.4,h=1+screwPad);
      }

      if(midsect){
        // dial
        dialW=TH*2.8;
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
                    inset = floor(i*10)%floor(dstep*2*10) > 10 ? 0 : 2;
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
        // Midsection
        translate([R2+0.5,-TH-screwPad*2-0.5,TH/2+0.5]) scale([-1,1,-1]){
          difference(){
            cube([R2/2,TH+screwPad*2+0.5,bH]);
            translate([TH+bH,0.01,0]) rotate([0,A-180,0]) translate([0,-0.5,-bH]) cube([R2/2,TH+screwPad*2+1,bH]);
            translate([R2/2+0.01,0.01,0]) cube([R2/2,TH+screwPad*2+1,bH]);
          }
        }
      }
      // Nozzle support
      difference(){
        translate([-3,0,-TH-0.5]) scale([-1,1,1]) cube([R1,TH,bH]);
        translate([-2,-0.5,TH-1]) rotate([0,-26,0]) scale([-1,1,1]) cube([R1*2,TH+1,bH]);
      }
    }
    if(midsect){
      // Text
      dstep = (R2*2*PI) / (R1*2*PI);
      maxD = DialA / dstep;
      for(i=[dstep:dstep*2:DialA]){
        mm=  round(i/dstep - maxD*0.5);
        rotate([0,-i,0])
          translate([R2-bH,TH,0]) rotate([90,0,0]) {
           scale([-1,1,1]) text(str(mm),size=4,valign="center",halign="center");
           scale([1,1,1]) translate([0,0,TH]) text(str(mm),size=4,valign="center",halign="center");
          }
      }
    }
    rotate([-90,0,0]) translate([0,0,TH+2]) BoltM2(l=20,inset=false);
    rotate([-90,0,0]) translate([R2-TH*2,(bH-TH)/2,TH]) BoltM2(l=20,inset=false);
    // Rubberband groove
    translate([R2-R2/2-1,-TH*2,-bH+2]) cube([2,TH*4,4]);
  }
}

//-------------- Assembly
*translate(){
  translate([0,-TH-0.8,0]) IndicatorArm();
  BasePlate();
  translate([0,-TH-6,0]) BasePlate(midsect=false);
}

//-------------- Export
translate(){
  translate([0,-8,4.8]) rotate([90,0,180-A]) translate([0,-TH-0.8,0]) IndicatorArm();
  translate([0,12,4]) rotate([-90]) BasePlate();
  translate([0,0,10])rotate([90]) translate([0,-TH-6,0]) BasePlate(midsect=false);
}



