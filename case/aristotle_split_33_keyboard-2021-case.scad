// Generating options
left=false;            // whether to print left side of board
right=false;           // whether to print right side of board
hinge=true;           // whether to print the hinge
open=false;            // whether the case is open or closed

// Variables
$fn=80;
height=15;            // Height of case in mm (PCB + ethernet thickness)
thickness=3;          // Thickness of case in mm
board_width=126.406;  // of actual board
board_height=96.303;  // of actual board
tent_radius=4.0;      // radius of hole for tenting screws
ethernet_x_pos=110;   // horizontal position (approx)
ethernet_y_pos=32.5;  // vertical position
ethernet_height=15.0; // ethernet port
mcu_x_pos=100.7;      // MCU horizontal position
mcu_y_pos=85;         // MCU vertical position (approx)
mcu_width=12;         // MCU port
switch_x_pos=65.2;    // switch horizontal position
switch_y_pos=18.0;    // switch vertical position (approx)
switch_thickness=6;   // thickness of hole for switch
switch_rotate=-24.0;  // angle of rotation for switch
switch_width=8;       // switch
thumb_x_pos=76;       // horizontal pos of thumb gap
thumb_y_pos=-10;      // vertical pos of thumb gap
thumb_width=42;       // width of shorter wall for thumb
thumb_thickness=7;    // thickness of pressed (thumb) key
hinge_radius = 3.5;   // radius of hinge
hinge_clearance=1.7;  // fudge factor so hinge pin clears board area
pin_radius = 1.1;     // radius of pin through hinge (actual radius: 1mm)
legFootRadius = 4;      // radius of tenting leg feet
legBaseRadius = 2;      // radius of tenting leg screw
legSlotFudge = 5.5; // amount to fudge screw slots to pin them against case

module board(side) {
    factor = (side=="right") ? 1 : 0;
    difference(){
        union(){
            // Enlarged board
            linear_extrude(height=height+thickness)
                import("/Users/bennett/keyboards/aristotle_split_33_keyboard-PCB-2021/case/aristotle_split_33_keyboard-2021-outline-enlarged.svg");
            // Hinge connector
            translate([board_width+hinge_clearance, board_height/2 - 2.55, factor*(height+thickness-hinge_radius) + hinge_radius*(1-factor)]) {
                rotate([90,0,0]) {
                    union(){
                        cylinder(h=board_height -2.15, r=hinge_radius, center=true);
                        translate([-hinge_radius,0,0])
                            cube([hinge_radius*2, hinge_radius*2, board_height - 2.15], center=true);
                    };
                };
            };
        };

        union(){
            // Original board dimensions, scaled up a bit
            resize([board_width + 1, board_height + 1, height + 1])
            translate([-.5, 0, (1-factor) * thickness - factor]){
                linear_extrude(height=height+1)
                    import("/Users/bennett/keyboards/aristotle_split_33_keyboard-PCB-2021/case/aristotle_split_33_keyboard-2021-outline.svg");
            };
            // Bottom tenting screw hole
            translate([121.2,5.5,factor*height-1]){
                linear_extrude(height=thickness+2)
                    circle(tent_radius);
            };
            // Top tenting screw hole
            translate([121.2,84,factor*height-1]){
                linear_extrude(height=thickness+2)
                    circle(tent_radius);
            };
            // Ethernet port
            translate([ethernet_x_pos, ethernet_y_pos, (1-factor)*thickness-factor]){
                cube(ethernet_height+1);
            };
            // Reduced height wall for thumbs
            translate([thumb_x_pos, thumb_y_pos, (1-factor)*(height+thickness-thumb_thickness)-factor]){
                cube([thumb_width, 30, thumb_thickness + 1]);
            };
            // Remove center from hinge and bore hole for pin
            translate([board_width+hinge_clearance, board_height/2 - 2.4, factor*(height+thickness-hinge_radius) + hinge_radius*(1-factor)]) {
                rotate([90,0,0]) {
                    union(){
                        cylinder(h=board_height+.1, r=pin_radius, center=true);
                        translate([-hinge_radius*0,0,-2.55])
                            cube([hinge_radius * 4+.01, hinge_radius * 2 +.01, board_height*2/3 - 8], center=true);
                    };
                };
            };
            // Finger hole to push board out of case
            translate([board_width/4*3,board_height*3/5,height/2+thickness/2])
                cylinder(h=height+thickness+1, r=9, center=true);

            if(side=="right"){
                // USB port
                translate([mcu_x_pos, mcu_y_pos, -factor]){
                    cube([mcu_width, mcu_width, height+1]);
                };
                // On/off switch
                translate([switch_x_pos, switch_y_pos, height-switch_thickness]){
                    rotate([0,0,switch_rotate]){
                        cube([switch_width, switch_width, switch_thickness]);
                    };
                };
            };
        };
    };
}

module hinge(side) {
    factor = (side=="right") ? 1 : 0;
    translate([board_width+hinge_clearance, board_height/2 - 2.4, factor * (height+thickness-hinge_radius) + hinge_radius*(1-factor)]) {
        rotate([90,180*factor-90,0]) {
            difference(){
                union(){
                translate([0,0,-2.55])
                    cylinder(h=board_height*2/3-9, r=hinge_radius, center=true);
                /* translate([height+thickness-hinge_radius,0,-2.55]) */
                translate([0,-hinge_radius,-(board_height*2/3-9)/2-2.55])
                    cube([(height+thickness-hinge_radius)*2, hinge_radius * 2+(legSlotFudge-legFootRadius+1), board_height*2/3-9], center=false);
                translate([-hinge_radius,0,-(board_height*2/3-9)/2-2.55])
                    cube([(height+thickness)*2, hinge_radius+legSlotFudge-legFootRadius+1, board_height*2/3-9], center=false);
                translate([(height+thickness-hinge_radius)*2,0,-2.55])
                    cylinder(h=board_height*2/3-9, r=hinge_radius, center=true);
                }
                union(){
                cylinder(h=board_height*2/3+.1, r=pin_radius, center=true);
                translate([0,0,-1.3])
                    cube([(height+thickness)*4, 10+hinge_radius*2+.1, board_height*2/3-35], center=true);
                translate([(height+thickness-hinge_radius)*2,0,0])
                    cylinder(h=board_height*2/3+.1, r=pin_radius, center=true);
                translate([(height+thickness-hinge_radius)*2,0,-1.3])
                    cube([(height+thickness)/2, hinge_radius*2+.1, board_height*2/3-35], center=true);
                translate([-5,9,18]) rotate([30,0,0])
                        cube([40,10,10]);
                // Slots to hold tenting legs
                translate([25.7,legSlotFudge,-25])
                    cylinder(h=23, r=legFootRadius, center=false);
                translate([25.7,legSlotFudge,-2])
                    cylinder(h=23, r=legBaseRadius, center=false);
                translate([17.87,legSlotFudge,-25])
                    cylinder(h=23, r=legBaseRadius, center=false);
                translate([17.87,legSlotFudge,-2])
                    cylinder(h=23, r=legFootRadius, center=false);
                translate([10.53,legSlotFudge,-25])
                    cylinder(h=23, r=legFootRadius, center=false);
                translate([10.53,legSlotFudge,-2])
                    cylinder(h=23, r=legBaseRadius, center=false);
                translate([3.2,legSlotFudge,-25])
                    cylinder(h=23, r=legBaseRadius, center=false);
                translate([3.2,legSlotFudge,-2])
                    cylinder(h=23, r=legFootRadius, center=false);
                }
            };
        };
    };
}

// Generate case parts

if (right)
    board("right");

if (left) {
    if (open) {
        rotate([0,180,0])
        translate([(-board_width-height-thickness+hinge_radius-hinge_clearance)*2,0,-height-thickness])
        board("left");
        };
    if (!open) {
        translate([0,0,-(height+thickness+.1)])
            board("left");
        };
    };

if (hinge) {
    if (open) {
        rotate([0,90,0])
        translate([-board_width-height-thickness+hinge_radius-hinge_clearance,0,board_width+height+thickness-hinge_radius+hinge_clearance])
            hinge("right");
        };
    if (!open) {
        rotate([0,180,0])
        /* translate([0*(-board_width-height+hinge_radius-hinge_clearance),0,0]) */
        translate([-2*board_width+-2*hinge_clearance,0,0])
        hinge("right");
        };
    };
