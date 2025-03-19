//OrbitJ, ImageJ-based semi-automated periorbit measurement tool 
//created by Jeffrey Peterson, MD, PhD
//Questions or comments, please email orbitjofficial@gmail.com
//or jpeter56@uic.edu

//Last updated 3-18-25

  getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec); // starts timer for the macro code
month = month+1;
DateString = " "+month+"-"+dayOfMonth+"-"+year;
run("Set Scale...", "distance=0 known=0 unit=pixel");
  roiManager("reset") 
  run("Remove Overlay");
//This section rotates image if you want
ID = getImageID(); 
selectImage(ID);  //make sure we still have the same image
//	yes_no_start = 0
	yes_no_start = getBoolean("Rotate image?");
	if(yes_no_start==1) {

yes_no = 0; //controls if you can escape the while loop to ensure user is 
//happy with choice of rotation
snapshot();
while (yes_no<1) {
	roiManager("reset")
	setTool("line");
	waitForUser("Rotation","Drag left mouse to make a vertical line\n"
	+"across the face to specify the vertical axis\n"
	+" \n"
	+"FYI: Left click to reset selection\n"
	+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
	+"Reset zoom: Ctrl/Cmd+4");
	setSelectionName("Rotation ref line");
	 roiManager("Add");
	// roiManager("Rename", "Rotation ref line");
roi_idx = 0;
	  getSelectionCoordinates( x, y );
	toScaled(x,y);
	print("X data");
	Array.print(x);
	print("Y data");
	Array.print(y);
	ang=getValue("Angle");
	print("Angle");
	print(ang);

	if(ang<0){
		ang=ang+180;
	}

	ang_correction = (90-ang)*(-1);
	print("Rotation");
	print(ang_correction);
	
	run("Rotate... ", "angle=ang_correction grid=1 interpolation=Bilinear");
	RoiManager.selectByName("Rotation ref line");
	RoiManager.rotate(ang_correction);
	RoiManager.selectByName("Rotation ref line");
	//selectionContains(x, y)
	//Returns true if the point x,y is inside the current selection. Aborts the macro if there is no selection. See also: Roi.contains

	yes_no = getBoolean("Are you happy with the rotation?");
	if(yes_no==0) {
		reset();
		RoiManager.selectByName("Rotation ref line");
		RoiManager.rotate((-1)*ang_correction);
		RoiManager.selectByName("Rotation ref line");
roiManager("Set Color", "yellow");
		}
	}
}else{
	run("Rotate... ", "angle=0 grid=1 interpolation=Bilinear");
	  roi_idx = -1;}

rotation = getValue("rotation.angle");
print("Rotated by: "+rotation+" deg");
  run("Select None"); 

//This section lets user select left and R irises to set the scale for subsequent measures

  run("Set Measurements...", "centroid center bounding shape invert redirect=None decimal=3");
    while (isOpen("y = a+bx+cx^2+dx^3+ex^4")) {
         selectWindow("y = a+bx+cx^2+dx^3+ex^4"); 
         run("Close" );}
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
    if (isOpen("Log")) {
         selectWindow("Log");
         run("Close" );}
    if (isOpen("XY Coordinates")) {
         selectWindow("XY Coordinates");
         run("Close" );}
 //closes open image windows
//    while (nImages()>0) {
  //        selectImage(nImages());  
 //         run("Close");
  //  }
  run("Select None");

//  Image.removeScale(); //removes any image scale

setTool("oval");


selectImage(ID);  //make sure we still have the same image
run("Select None");
error_check = 0;
while (error_check<1) {
circularity = 0;
 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
waitForUser("Right side iris","Right Iris Bounding Circle: Once you've made circle, click ok!\n"
+" \n"
+"Shortcuts: Shift+left click for circle, shift+Ctrl/Cmd+left click for center circle\n"
+"Reset selection: Ctrl/Cmd+Shift+A or left click\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Set Measurements...", "centroid center bounding shape redirect=None decimal=3");
run("Measure");
circularity = Table.getColumn("Circ.");
if(circularity[0]>0.98){
	error_check=1;}
	else{
	 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Not a perfect circle!\n"
	+"Hold Shift+left click when making circle.");
	run("Select None");}
}
roiManager("Add");

run("Measure");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Iris");
x_R_iris_center = Table.getColumn("X");
y_R_iris_center = Table.getColumn("Y");
R_iris_dia = Table.getColumn("Width");
run("Select None");
makeSelection("Point", x_R_iris_center, y_R_iris_center);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Iris Center");
 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}


//---------------------------------------------
//Now do left L iris so that we can avg the two measurements
error_check = 0;
while (error_check<1) {
 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
selectImage(ID);  //make sure we still have the same image
  run("Select None");
//  makeOval(3767, 1976, 387, 387);
waitForUser("Left side iris","Left Iris Bounding Circle: Once you've made circle, click ok!\n"
+" \n"
+"Shortcuts: Shift+left click for circle, shift+Ctrl/Cmd+left click for center circle\n"
+"Reset selection: Ctrl/Cmd+Shift+A or left click\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
circularity = Table.getColumn("Circ.");
if(circularity[0] >0.98){
	error_check=1;}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Not a perfect circle!\n"
	+"Hold Shift+left click when making circle.");
	run("Select None");}
}

roiManager("Add");
run("Set Measurements...", "centroid center bounding shape redirect=None decimal=3");

run("Measure");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Iris");
x_L_iris_center = Table.getColumn("X");
y_L_iris_center = Table.getColumn("Y");

print("R Iris Center X:",x_R_iris_center[0]);

print("L Iris Center X:",x_L_iris_center[0]);

L_iris_dia = Table.getColumn("Width");
run("Select None");
makeSelection("Point", x_L_iris_center, y_L_iris_center);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Iris Center");
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
run("Select None");
//--------------------------------------
//Averages the two iris diameters and sets the scale to 11.7mm diameter

iris_dia_avg = (L_iris_dia[0] + R_iris_dia[0])/2;

////---------------------------------------------
roiManager("Show None");
selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {

    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Right Superior Brow Line","Right Superior Brow Line: Do you have your fifteen points up? If so then click ok!\n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");

run("Measure");
if(nResults ==15){
	  getSelectionCoordinates( x_R_eyebrow_top, y_R_eyebrow_top );
error_check=fit_error_check( x_R_eyebrow_top, y_R_eyebrow_top ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 15 points required!");
}
}

selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_R_eyebrow_top, y_R_eyebrow_top );
toScaled(x_R_eyebrow_top,y_R_eyebrow_top);


run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_R_eyebrow_top = Table.getColumn("X");
y_R_eyebrow_top = Table.getColumn("Y");

x_R_eyebrow_top = Array.reverse(x_R_eyebrow_top); //puts arrays in order from medial to lateral for right eye (bc X goes from larger to smaller from medial to lateral)
y_R_eyebrow_top = Array.reverse(y_R_eyebrow_top);


print("R eyebrow top X points:");
Array.print(x_R_eyebrow_top);
print("R eyebrow top Y points:");
Array.print(y_R_eyebrow_top);


Array.getStatistics(x_R_eyebrow_top, x_R_eyebrow_topmin, x_R_eyebrow_topmax,x_R_eyebrow_topmean,x_R_eyebrow_topstd);
Array.getStatistics(y_R_eyebrow_top, y_R_eyebrow_topmin, y_R_eyebrow_topmax,y_R_eyebrow_topmean,y_R_eyebrow_topstd);
print("R_eyebrow Top");
  print("   x min: "+x_R_eyebrow_topmin);
  print("   x max: "+x_R_eyebrow_topmax);
  
  roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Superior Brow Line");
//run("Select None");
setKeyDown("alt");
makeSelection("point",x_R_eyebrow_top,x_R_eyebrow_top);//erases points manually
//---------------------------------------------
selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Right Inferior Brow Line","Right Inferior Brow Line: Do you have your fifteen points up? If so then click ok!\n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==15){
 getSelectionCoordinates( x_R_eyebrow_bot, y_R_eyebrow_bot );
error_check=fit_error_check( x_R_eyebrow_bot, y_R_eyebrow_bot ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 15 points required!");
}
}
selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_R_eyebrow_bot, y_R_eyebrow_bot );
  toScaled(x_R_eyebrow_bot,y_R_eyebrow_bot);

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_R_eyebrow_bot = Table.getColumn("X");
y_R_eyebrow_bot = Table.getColumn("Y");

x_R_eyebrow_bot = Array.reverse(x_R_eyebrow_bot); //puts arrays in order from medial to lateral for right eye (bc X goes from larger to smaller from medial to lateral)
y_R_eyebrow_bot = Array.reverse(y_R_eyebrow_bot);


print("R eyebrow bot X points:");
Array.print(x_R_eyebrow_bot);
print("R eyebrow bot Y points:");
Array.print(y_R_eyebrow_bot);
Array.getStatistics(x_R_eyebrow_bot, x_R_eyebrow_botmin, x_R_eyebrow_botmax,x_R_eyebrow_botmean,x_R_eyebrow_botstd);
Array.getStatistics(y_R_eyebrow_bot, y_R_eyebrow_botmin, y_R_eyebrow_botmax,y_R_eyebrow_botmean,y_R_eyebrow_botstd);
print("R_eyebrow Bottom");
  print("   x min: "+x_R_eyebrow_botmin);
  print("   x max: "+x_R_eyebrow_botmax);


  roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Inferior Brow Line");
//roiManager("Show None");
setKeyDown("alt");
makeSelection("point",x_R_eyebrow_bot,x_R_eyebrow_bot);//erases points manually

//--------------------------------------------- 
selectImage(ID);  //make sure we still have the same image
run("Select None");
	yes_R_lid_crease = 0;
//	yes_R_lid_crease = getBoolean("Is there a right lid crease?");
	if(yes_R_lid_crease==1) {
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Right side: Lid Crease","Right Lid Crease: Do you have your *ten* points up? If so then click ok!\n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==10){
 getSelectionCoordinates( x_R_lid_crease, y_R_lid_crease);
error_check=fit_error_check(  x_R_lid_crease, y_R_lid_crease); //when output is 0, code repeats, when 1, code moves forward

	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 10 points required!");
}

}

selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_R_lid_crease, y_R_lid_crease );
toScaled(x_R_lid_crease,y_R_lid_crease);

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_R_lid_crease = Table.getColumn("X");
y_R_lid_crease = Table.getColumn("Y");

x_R_lid_crease = Array.reverse(x_R_lid_crease); //puts arrays in order from medial to lateral for right eye (bc X goes from larger to smaller from medial to lateral)
y_R_lid_crease = Array.reverse(y_R_lid_crease);


print("R eyelid crease X points:");
Array.print(x_R_lid_crease);
print("R eyelid crease  Y points:");
Array.print(y_R_lid_crease);
	}
	else {
	x_R_lid_crease =newArray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	y_R_lid_crease =newArray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);}
Array.getStatistics(x_R_lid_crease, x_R_lid_creasemin, x_R_lid_creasemax, x_R_lid_creasemean,x_R_lid_creasestd);
Array.getStatistics(y_R_lid_crease, y_R_lid_creasemin, y_R_lid_creasemax, y_R_lid_creasemean,y_R_lid_creasestd);

	if(yes_R_lid_crease==1) {
print("R_eyebrow Bottom");
  print("   x min: "+x_R_lid_creasemin);
  print("   x max: "+x_R_lid_creasemax);
  
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Lid Crease");
//roiManager("Show None");
setKeyDown("alt");
makeSelection("point", x_R_lid_crease, y_R_lid_crease);//erases points manually
	}
	
	//---------------------------------------------
//R Upper Medial Canthus  to Upper Punctum
  selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Right side: Upper Medial Canthus Region","Right eye: Click four points from medial canthus to *upper* punctum. \n"
+" \n"
+"The puntum is either where a visible bend occurs in the lid,  \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==4){
getSelectionCoordinates(x_R_upper_med_canth,y_R_upper_med_canth);
error_check=fit_error_check(x_R_upper_med_canth,y_R_upper_med_canth); //when output is 0, code repeats, when 1, code moves forward

	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 4 points required!");
}

}

selectImage(ID);  //make sure we still have the same image

run("Measure");
Table.sort("X"); //Sorting from smalled to largest so that the user can select points in any order
x_R_upper_med_canth = Table.getColumn("X");
y_R_upper_med_canth = Table.getColumn("Y");

x_R_upper_med_canth = Array.reverse(x_R_upper_med_canth); //puts arrays in order from medial to lateral for right eye (bc X goes from larger to smaller from medial to lateral)
y_R_upper_med_canth = Array.reverse(y_R_upper_med_canth);

//  getSelectionCoordinates( x_R_upper_med_canth, y_R_upper_med_canth );
toScaled( x_R_upper_med_canth, y_R_upper_med_canth);

Array.getStatistics(x_R_upper_med_canth, x_R_upper_med_canthmin, x_R_upper_med_canthmax, x_R_upper_med_canthmean, x_R_upper_med_canthstd);
Array.getStatistics(y_R_upper_med_canth, y_R_upper_med_canthmin, y_R_upper_med_canthmax, y_R_upper_med_canthmean, y_R_upper_med_canthstd);

roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Med Canth to Upper Punctum");


setKeyDown("alt");
makeSelection("point",  x_R_upper_med_canth, y_R_upper_med_canth );//erases points manually
	 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
       
  //---------------------------------------------
  //R Upper Lid Margin: R upper puntum to R lateral canthus
 selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Right side: Upper Lid Margin","Right Upper Lid Margin: Do you have your *ten* points up? If so then click ok!\n"
+" \n"
+"Draw from *upper* punctum to lateral canthus.\n"
+"The puntum is either where a visible bend occurs in the lid,  \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==10){
getSelectionCoordinates( x_R_upper_lid, y_R_upper_lid );
error_check=fit_error_check( x_R_upper_lid, y_R_upper_lid ); //when output is 0, code repeats, when 1, code moves forward

	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 10 points required!");
}
}
selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_R_upper_lid, y_R_upper_lid );
toScaled(x_R_upper_lid,y_R_upper_lid);
 
run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_R_upper_lid = Table.getColumn("X");
y_R_upper_lid = Table.getColumn("Y");

x_R_upper_lid = Array.reverse(x_R_upper_lid); //puts arrays in order from medial to lateral for right eye (bc X goes from larger to smaller from medial to lateral)
y_R_upper_lid = Array.reverse(y_R_upper_lid);


print("R upper lid X points:");
Array.print(x_R_upper_lid);
print("R upper lid Y points:");
Array.print(y_R_upper_lid);
Array.getStatistics(x_R_upper_lid, x_R_upper_lidmin, x_R_upper_lidmax, x_R_upper_lidmean, x_R_upper_lidstd);
Array.getStatistics(y_R_upper_lid, y_R_upper_lidmin, y_R_upper_lidmax, y_R_upper_lidmean, y_R_upper_lidstd);
print("R_eyebrow Bottom");
  print("   x min: "+x_R_upper_lidmin);
  print("   x max: "+x_R_upper_lidmax);
  
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Upper Lid Margin");

setKeyDown("alt");
makeSelection("point",  x_R_upper_lid, y_R_upper_lid );//erases points manually
//---------------------------------------------
//R Upper Medial Canthus to Lower Punctum
  selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Right side: Lower Medial Canthus Region","Right eye: Click four points from medial canthus to *lower* punctum. \n"
+" \n"
+"The puntum is either where a visible bend occurs in the lid,  \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==4){
getSelectionCoordinates(x_R_lower_med_canth,y_R_lower_med_canth);
error_check=fit_error_check(x_R_lower_med_canth,y_R_lower_med_canth); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 4 points required!");
}

}

selectImage(ID);  //make sure we still have the same image

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_R_lower_med_canth = Table.getColumn("X");
y_R_lower_med_canth = Table.getColumn("Y");

x_R_lower_med_canth = Array.reverse(x_R_lower_med_canth); //puts arrays in order from medial to lateral for right eye (bc X goes from larger to smaller from medial to lateral)
y_R_lower_med_canth = Array.reverse(y_R_lower_med_canth);

//  getSelectionCoordinates( x_R_lower_med_canth, y_R_lower_med_canth );
toScaled( x_R_lower_med_canth, y_R_lower_med_canth);

Array.getStatistics(x_R_lower_med_canth, x_R_lower_med_canthmin, x_R_lower_med_canthmax, x_R_lower_med_canthmean, x_R_lower_med_canthstd);
Array.getStatistics(y_R_lower_med_canth, y_R_lower_med_canthmin, y_R_lower_med_canthmax, y_R_lower_med_canthmean, y_R_lower_med_canthstd);

roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Med Canth to Lower Punctum");


setKeyDown("alt");
makeSelection("point",  x_R_lower_med_canth, y_R_lower_med_canth );//erases points manually
	 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
//---------------------------------------------
//R Lower Lid Margin
selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Right side: Lower Lid Margin","Right Lower Lid Margin: Do you have your *ten* points up? If so then click ok!\n"
+" \n"
+"Draw from *lower* punctum to lateral canthus.\n"
+"The puntum is either where a visible bend occurs in the lid,  \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==10){
getSelectionCoordinates( x_R_lower_lid, y_R_lower_lid );
error_check=fit_error_check( x_R_lower_lid, y_R_lower_lid ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 10 points required!");
}
}

selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_R_lower_lid, y_R_lower_lid );
toScaled(x_R_lower_lid,y_R_lower_lid);

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_R_lower_lid = Table.getColumn("X");
y_R_lower_lid = Table.getColumn("Y");

x_R_lower_lid = Array.reverse(x_R_lower_lid); //puts arrays in order from medial to lateral for right eye (bc X goes from larger to smaller from medial to lateral)
y_R_lower_lid = Array.reverse(y_R_lower_lid);



print("R lower lid X points:");
Array.print(x_R_lower_lid);
print("R lower lid Y points:");
Array.print(y_R_lower_lid);

Array.getStatistics(x_R_lower_lid, x_R_lower_lidmin, x_R_lower_lidmax, x_R_lower_lidmean, x_R_lower_lidstd);
Array.getStatistics(y_R_lower_lid, y_R_lower_lidmin, y_R_lower_lidmax, y_R_lower_lidmean, y_R_lower_lidstd);
print("R lower lid");
  print("   x min: "+x_R_lower_lidmin);
  print("   x max: "+x_R_lower_lidmax);

roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Lower Lid Margin");

setKeyDown("alt");
makeSelection("point", x_R_lower_lid, y_R_lower_lid );//erases points manually
   //---------------------------------------------



//---------------------------------------------
//---------------------------------------------
//---------------------------------------------
//---------------------------------------------
//---------------------------------------------
//---------------------------------------------
//LEFT EYE CURVATURE MEASURES
roiManager("Show None");
selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Left Superior Brow Line","Left Superior Brow Line: Do you have your fifteen points up? If so then click ok!\n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==15){
getSelectionCoordinates( x_L_eyebrow_top, y_L_eyebrow_top );
error_check=fit_error_check(  x_L_eyebrow_top, y_L_eyebrow_top ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 15 points required!");
}
}
selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_L_eyebrow_top, y_L_eyebrow_top );
toScaled(x_L_eyebrow_top,y_L_eyebrow_top);

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_L_eyebrow_top = Table.getColumn("X");
y_L_eyebrow_top = Table.getColumn("Y");


print("L eyebrow top X points:");
Array.print(x_L_eyebrow_top);
print("L eyebrow top Y points:");
Array.print(y_L_eyebrow_top);

Array.getStatistics(x_L_eyebrow_top, x_L_eyebrow_topmin, x_L_eyebrow_topmax, x_L_eyebrow_topmean, x_L_eyebrow_topstd);
Array.getStatistics(y_L_eyebrow_top, y_L_eyebrow_topmin, y_L_eyebrow_topmax, y_L_eyebrow_topmean, y_L_eyebrow_topstd);
print("R_eyebrow Top");
  print("   x min: "+x_L_eyebrow_topmin);
  print("   x max: "+x_L_eyebrow_topmax);
  
  roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Superior Brow Line");
//run("Select None");
setKeyDown("alt");
makeSelection("point",x_L_eyebrow_top,x_L_eyebrow_top);//erases points manually


//---------------------------------------------
selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Left Inferior Brow Line","Left Inferior Brow Line: Do you have your fifteen points up? If so then click ok!\n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==15){
getSelectionCoordinates( x_L_eyebrow_bot, y_L_eyebrow_bot );
error_check=fit_error_check( x_L_eyebrow_bot, y_L_eyebrow_bot ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 15 points required!");
}
}

selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_L_eyebrow_bot, y_L_eyebrow_bot );
toScaled(x_L_eyebrow_bot,y_L_eyebrow_bot);

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_L_eyebrow_bot = Table.getColumn("X");
y_L_eyebrow_bot = Table.getColumn("Y");


print("L eyebrow bot X points:");
Array.print(x_L_eyebrow_bot);
print("L eyebrow bot Y points:");
Array.print(y_L_eyebrow_bot);

Array.getStatistics(x_L_eyebrow_bot, x_L_eyebrow_botmin, x_L_eyebrow_botmax, x_L_eyebrow_botmean, x_L_eyebrow_botstd);
Array.getStatistics(y_L_eyebrow_bot, y_L_eyebrow_botmin, y_L_eyebrow_botmax, y_L_eyebrow_botmean, y_L_eyebrow_botstd);
print("R_eyebrow Bottom");
  print("   x min: "+x_L_eyebrow_botmin);
  print("   x max: "+x_L_eyebrow_botmax);


  roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Inferior Brow Line");
//roiManager("Show None");
setKeyDown("alt");
makeSelection("point",x_L_eyebrow_bot,x_L_eyebrow_bot);//erases points manually



//---------------------------------------------
selectImage(ID);  //make sure we still have the same image
run("Select None");
	yes_L_lid_crease = 0;
// yes_L_lid_crease = getBoolean("Is there a left lid crease?");
	if(yes_L_lid_crease==1) {

setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Left side: Lid Crease","Left Lid Crease: Do you have your *ten* points up? If so then click ok!\n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==10){
getSelectionCoordinates( x_L_lid_crease, y_L_lid_crease );
error_check=fit_error_check( x_L_lid_crease, y_L_lid_crease ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 10 points required!");
}
}
selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_L_lid_crease, y_L_lid_crease );
toScaled(x_L_lid_crease,y_L_lid_crease);

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_L_lid_crease = Table.getColumn("X");
y_L_lid_crease = Table.getColumn("Y");


print("L eyelid crease X points:");
Array.print(x_L_lid_crease);
print("L eyelid crease Y points:");
Array.print(y_L_lid_crease);
}
	else {
	x_L_lid_crease =newArray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	y_L_lid_crease =newArray(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);}


Array.getStatistics(x_L_lid_crease, x_L_lid_creasemin, x_L_lid_creasemax, x_L_lid_creasemean, x_L_lid_creasestd);
Array.getStatistics(y_L_lid_crease, y_L_lid_creasemin, y_L_lid_creasemax, y_L_lid_creasemean, y_L_lid_creasestd);

	if(yes_L_lid_crease==1) {
print("L_eyebrow Bottom");
  print("   x min: "+x_L_lid_creasemin);
  print("   x max: "+x_L_lid_creasemax);
  
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Lid Crease");
//roiManager("Show None");
setKeyDown("alt");
makeSelection("point", x_L_lid_crease, y_L_lid_crease);//erases points manually
	}
//---------------------------------------------
//L Upper Medial Canthus  to Upper Punctum
  selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Left side: Upper Medial Canthus Region","Left eye: Click four points from medial canthus to *upper* punctum. \n"
+" \n"
+"The puntum is either where a visible bend occurs in the lid,  \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==4){
getSelectionCoordinates( x_L_upper_med_canth, y_L_upper_med_canth);
error_check=fit_error_check( x_L_upper_med_canth, y_L_upper_med_canth ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 4 points required!");
}
}

selectImage(ID);  //make sure we still have the same image

run("Measure");
Table.sort("X"); //Sorting from smalled to largest so that the user can select points in any order
x_L_upper_med_canth = Table.getColumn("X");
y_L_upper_med_canth = Table.getColumn("Y");
//  getSelectionCoordinates( x_L_upper_med_canth, y_L_upper_med_canth );
toScaled( x_L_upper_med_canth, y_L_upper_med_canth);

Array.getStatistics(x_L_upper_med_canth, x_L_upper_med_canthmin, x_L_upper_med_canthmax, x_L_upper_med_canthmean, x_L_upper_med_canthstd);
Array.getStatistics(y_L_upper_med_canth, y_L_upper_med_canthmin, y_L_upper_med_canthmax, y_L_upper_med_canthmean, y_L_upper_med_canthstd);

roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Med Canth to Upper Punctum");


setKeyDown("alt");
makeSelection("point",  x_L_upper_med_canth, y_L_upper_med_canth );//erases points manually
	 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
       
//---------------------------------------------    
//Upper Lid: L Upper Punctum to Lateral Canthus
selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Left side: Upper Lid Margin","Left Upper Lid Margin: Do you have your *ten* points up? If so then click ok!\n"
+" \n"
+"Draw from *upper* punctum to lateral canthus.\n"
+"The puntum is either where a visible bend occurs in the lid, \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==10){
getSelectionCoordinates( x_L_upper_lid, y_L_upper_lid );
error_check=fit_error_check( x_L_upper_lid, y_L_upper_lid ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 10 points required!");
}
}

selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_L_upper_lid, y_L_upper_lid );
toScaled(x_L_upper_lid,y_L_upper_lid);

run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_L_upper_lid = Table.getColumn("X");
y_L_upper_lid = Table.getColumn("Y");

print("L upper lid X points:");
Array.print(x_L_upper_lid);
print("L upper lid Y points:");
Array.print(y_L_upper_lid);

Array.getStatistics(x_L_upper_lid, x_L_upper_lidmin, x_L_upper_lidmax, x_L_upper_lidmean, x_L_upper_lidstd);
Array.getStatistics(y_L_upper_lid, y_L_upper_lidmin, y_L_upper_lidmax, y_L_upper_lidmean, y_L_upper_lidstd);
print("R_eyebrow Bottom");
  print("   x min: "+x_L_upper_lidmin);
  print("   x max: "+x_L_upper_lidmax);
  
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Upper Lid Margin");

setKeyDown("alt");
makeSelection("point",  x_L_upper_lid, y_L_upper_lid );//erases points manually
//---------------------------------------------
//L Lower Medial Canthus to Lower Punctum
  selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Left side: Lower Medial Canthus Region","Left eye: Click four points from medial canthus to *Lower* punctum. \n"
+" \n"
+"The puntum is either where a visible bend occurs in the lid,  \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==4){
getSelectionCoordinates(x_L_lower_med_canth, y_L_lower_med_canth );
error_check=fit_error_check(x_L_lower_med_canth, y_L_lower_med_canth ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 4 points required!");
}
}

selectImage(ID);  //make sure we still have the same image

run("Measure");
Table.sort("X"); //Sorting from smalled to largest so that the user can select points in any order
x_L_lower_med_canth = Table.getColumn("X");
y_L_lower_med_canth = Table.getColumn("Y");
//  getSelectionCoordinates( x_L_lower_med_canth, y_L_lower_med_canth );
toScaled( x_L_lower_med_canth, y_L_lower_med_canth);

Array.getStatistics(x_L_lower_med_canth, x_L_lower_med_canthmin, x_L_lower_med_canthmax, x_L_lower_med_canthmean, x_L_lower_med_canthstd);
Array.getStatistics(y_L_lower_med_canth, y_L_lower_med_canthmin, y_L_lower_med_canthmax, y_L_lower_med_canthmean, y_L_lower_med_canthstd);

roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Med Canth to Lower Punctum");


setKeyDown("alt");
makeSelection("point",  x_L_lower_med_canth, y_L_lower_med_canth );//erases points manually
	 if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
//---------------------------------------------
//Lower Lid: L Lower Punctum to Lateral Canthus
selectImage(ID);  //make sure we still have the same image
run("Select None");
setTool("multipoint");
error_check = 0;
while (error_check<1) {
    if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}
selectImage(ID);  //make sure we still have the same image
waitForUser("Left side: Lower Lid Margin","Left Lower Lid Margin: Do you have your *ten* points up? If so then click ok!\n"
+" \n"
+"Draw from *lower* punctum to lateral canthus.\n"
+"The puntum is either where a visible bend occurs in the lid,  \n"
+"or where the white sclera of the globe is no longer visible. \n"
+" \n"
+"Shortcuts: Alt+Click to erase point, Ctrl/Cmd+Shift+A to erase all points\n"
+"Zoom in: +, Zoom out: -, Pan view: Space+Click and drag\n"
+"Reset zoom: Ctrl/Cmd+4");
run("Measure");
if(nResults ==10){
getSelectionCoordinates(x_L_lower_lid, y_L_lower_lid );
error_check=fit_error_check(x_L_lower_lid, y_L_lower_lid ); //when output is 0, code repeats, when 1, code moves forward
	isOpen("Results") {
        selectWindow("Results"); 
       run("Close" );}}
	else{
if (isOpen("Results")) {
        selectWindow("Results"); 
       run("Close" );}
	waitForUser("Exactly 10 points required!");
}
}
selectImage(ID);  //make sure we still have the same image
  getSelectionCoordinates( x_L_lower_lid, y_L_lower_lid );
toScaled(x_L_lower_lid,y_L_lower_lid);


run("Measure");
Table.sort("X"); //Sorting from smallest to largest so that the user can select points in any order
x_L_lower_lid = Table.getColumn("X");
y_L_lower_lid = Table.getColumn("Y");

Array.getStatistics(x_L_lower_lid, x_L_lower_lidmin, x_L_lower_lidmax, x_L_lower_lidmean, x_L_lower_lidstd);
Array.getStatistics(y_L_lower_lid, y_L_lower_lidmin, y_L_lower_lidmax, y_L_lower_lidmean, y_L_lower_lidstd);
print("R_eyebrow Bottom");
  print("   x min: "+x_L_lower_lidmin);
  print("   x max: "+x_L_lower_lidmax);
  
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Lower Lid Margin");

setKeyDown("alt");
makeSelection("point", x_L_lower_lid, y_L_lower_lid );//erases points manually



//-----------------------------------------------------------------------------------------
//Calculate Medial canthus, lateral canthus positions by averaging values from upper and lower lid points     




x_R_med_canth = (x_R_lower_med_canth[0] + x_R_upper_med_canth[0])/2;
y_R_med_canth = (y_R_lower_med_canth[0] + y_R_upper_med_canth[0])/2;


x_R_lat_canth = (x_R_upper_lid[x_R_upper_lid.length-1] + x_R_lower_lid[x_R_lower_lid.length-1])/2; //assumes first element is medial canthus, last element is lateral
y_R_lat_canth = (y_R_upper_lid[y_R_upper_lid.length-1] + y_R_lower_lid[y_R_lower_lid.length-1])/2; //assumes first element is medial canthus, last element is lateral


x_L_med_canth = (x_L_lower_med_canth[0] + x_L_upper_med_canth[0])/2;
y_L_med_canth = (y_L_lower_med_canth[0] + y_L_upper_med_canth[0])/2;


x_L_lat_canth = (x_L_upper_lid[x_L_upper_lid.length-1] + x_L_lower_lid[x_L_lower_lid.length-1])/2; //assumes first element is medial canthus, last element is lateral
y_L_lat_canth = (y_L_upper_lid[y_L_upper_lid.length-1] + y_L_lower_lid[y_L_lower_lid.length-1])/2; //assumes first element is medial canthus, last element is lateral



//Calculated upper punctum position using the same method

x_R_upper_punc = (x_R_upper_lid[0] + x_R_upper_med_canth[x_R_upper_med_canth.length-1])/2;
y_R_upper_punc = (y_R_upper_lid[0] + y_R_upper_med_canth[x_R_upper_med_canth.length-1])/2;

x_L_upper_punc = (x_L_upper_lid[0] + x_L_upper_med_canth[x_L_upper_med_canth.length-1])/2;
y_L_upper_punc = (y_L_upper_lid[0] + y_L_upper_med_canth[x_L_upper_med_canth.length-1])/2;




selectImage(ID);  //make sure we still have the same image
run("Select None");
makePoint(x_R_med_canth, y_R_med_canth, "small yellow hybrid");
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Med Canthus");
setKeyDown("alt");
makePoint("point", x_R_med_canth, y_R_med_canth );//erases points manually
setKeyDown("none");

makePoint(x_R_lat_canth, y_R_lat_canth, "small yellow hybrid");
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Lat Canthus");
setKeyDown("alt");
makePoint("point", x_R_lat_canth, y_R_lat_canth );//erases points manually
setKeyDown("none");


selectImage(ID);  //make sure we still have the same image
run("Select None");
makePoint(x_L_med_canth, y_L_med_canth, "small yellow hybrid");
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Med Canthus");
setKeyDown("alt");
makePoint("point", x_L_med_canth, y_L_med_canth );//erases points manually
setKeyDown("none");

makePoint(x_L_lat_canth, y_L_lat_canth, "small yellow hybrid");
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Lat Canthus");
setKeyDown("alt");
makePoint("point", x_L_lat_canth, y_L_lat_canth );//erases points manually
setKeyDown("none");

  if (isOpen("Results")) {
         selectWindow("Results"); 
         run("Close" );}


//-------------------------------------------
//Create fit curves

	
//Lateral limbus X-positions
x_R_med_limbus = x_R_iris_center[0]+R_iris_dia[0]/2;
x_R_lat_limbus = x_R_iris_center[0]-R_iris_dia[0]/2;
x_L_med_limbus = x_L_iris_center[0]-L_iris_dia[0]/2;
x_L_lat_limbus = x_L_iris_center[0]+L_iris_dia[0]/2;

//MRD1/2
selectImage(ID);  //make sure we still have the same image

yfit_R_upper_lid = calc_Y(x_R_iris_center[0], x_R_upper_lid, y_R_upper_lid);
yfit_R_upper_lid_ML = calc_Y(x_R_med_limbus, x_R_upper_lid, y_R_upper_lid);
yfit_R_upper_lid_LL = calc_Y(x_R_lat_limbus, x_R_upper_lid, y_R_upper_lid);

yfit_R_lower_lid = calc_Y(x_R_iris_center[0], x_R_lower_lid, y_R_lower_lid);


R_MRD1 = y_R_iris_center[0]-yfit_R_upper_lid;
selectImage(ID);  //make sure we still have the same image	
		makeLine(x_R_iris_center[0], yfit_R_upper_lid, x_R_iris_center[0], y_R_iris_center[0]);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R MRD1");
roiManager("Set Color", "cyan");
	selectImage(ID);  //make sure we still have the same image	
	    run("Set Measurements...", "centroid center bounding shape invert redirect=None decimal=3");
	     run("Select None");


R_MRD2 = yfit_R_lower_lid-y_R_iris_center[0];
selectImage(ID);  //make sure we still have the same image	
		makeLine(x_R_iris_center[0], yfit_R_lower_lid, x_R_iris_center[0], y_R_iris_center[0]);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R MRD2");
roiManager("Set Color", "magenta");
selectImage(ID);  //make sure we still have the same image

yfit_L_upper_lid = calc_Y(x_L_iris_center[0], x_L_upper_lid, y_L_upper_lid);
//yfit_L_upper_lid_ML = y_L_iris_center[0];
//yfit_L_upper_lid_LL = y_L_iris_center[0];
yfit_L_lower_lid = calc_Y(x_L_iris_center[0], x_L_lower_lid, y_L_lower_lid);

yfit_L_upper_lid_ML = calc_Y(x_L_med_limbus, x_L_upper_lid, y_L_upper_lid);
yfit_L_upper_lid_LL = calc_Y(x_L_lat_limbus, x_L_upper_lid, y_L_upper_lid);

L_MRD1 = y_L_iris_center[0]-yfit_L_upper_lid;
selectImage(ID);  //make sure we still have the same image	
		makeLine(x_L_iris_center[0], yfit_L_upper_lid, x_L_iris_center[0], y_L_iris_center[0]);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L MRD1");
roiManager("Set Color", "cyan");
	selectImage(ID);  //make sure we still have the same image	

		
L_MRD2 = yfit_L_lower_lid-y_L_iris_center[0];
selectImage(ID);  //make sure we still have the same image	
		makeLine(x_L_iris_center[0], yfit_L_lower_lid, x_L_iris_center[0], y_L_iris_center[0]);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L MRD2");
roiManager("Set Color", "magenta");

R_PFH=R_MRD1+R_MRD2; //Calculates palpebral fissue height
L_PFH=L_MRD1+L_MRD2;


//scleral show
R_sup_scleral_show = (y_R_iris_center[0]-(R_iris_dia[0])/2) - yfit_R_upper_lid;
R_inf_scleral_show = yfit_R_lower_lid-(y_R_iris_center[0]+(R_iris_dia[0])/2);
L_sup_scleral_show = (y_L_iris_center[0]-(L_iris_dia[0])/2) - yfit_L_upper_lid;
L_inf_scleral_show = yfit_L_lower_lid-(y_L_iris_center[0]+(L_iris_dia[0])/2);

print("R iris top");
print(y_R_iris_center[0]-(R_iris_dia[0])/2);
print("R iris bottom");
print(y_R_iris_center[0]+(R_iris_dia[0])/2);
print("R upper lid margin");
print(yfit_R_upper_lid);
print("R lower lid margin");
print(yfit_R_lower_lid);

if(R_sup_scleral_show<0){
	R_sup_scleral_show =0;
}
if(R_inf_scleral_show<0){
	R_inf_scleral_show =0;
}
if(L_sup_scleral_show<0){
	L_sup_scleral_show =0;
}
if(L_inf_scleral_show<0){
	L_inf_scleral_show =0;
}

//Canthal tilt R
R_canthal_tilt = atan((y_R_lat_canth-y_R_med_canth)/(x_R_lat_canth-x_R_med_canth))*180/3.14159; //for positive x axis works
print("R canthal tilt: ");
print(R_canthal_tilt);

R_PFW = abs(x_R_lat_canth-x_R_med_canth);
L_PFW = abs(x_L_lat_canth-x_L_med_canth);

//if(R_canthal_tilt>90){
//R_canthal_tilt = 180-R_canthal_tilt;
//}
selectImage(ID);  //make sure we still have the same image
makeLine(x_R_med_canth, y_R_med_canth, x_R_lat_canth, y_R_lat_canth);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Canthal Tilt");
roiManager("Set Color", "orange");
//Canthal tilt L
L_canthal_tilt = atan((y_L_lat_canth-y_L_med_canth)/(-x_L_lat_canth+x_L_med_canth))*180/3.14159; //for positive x axis works
print("L canthal tilt: ");
print(L_canthal_tilt);
//if(L_canthal_tilt>90){
//L_canthal_tilt = 180-L_canthal_tilt;
//}
selectImage(ID);  //make sure we still have the same image
makeLine(x_L_med_canth, y_L_med_canth, x_L_lat_canth, y_L_lat_canth);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Canthal Tilt");
roiManager("Set Color", "orange");
//Vertical dystopia
Vert_dystopia_med = Math.abs(y_R_med_canth-y_L_med_canth);
Vert_dystopia_iris_center = Math.abs(y_R_iris_center[0]-y_L_iris_center[0]);
Vert_dystopia_lat = Math.abs(y_R_lat_canth-y_L_lat_canth);

x_med_canth_avg = (x_R_med_canth+x_L_med_canth)/2;
y_med_canth_avg = (y_R_med_canth+y_L_med_canth)/2;
selectImage(ID);  //make sure we still have the same image
makeLine(x_med_canth_avg, y_med_canth_avg-Vert_dystopia_med/2, x_med_canth_avg, y_med_canth_avg+Vert_dystopia_med/2);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "Vert Dystopia Med Canth");
roiManager("Set Color", "yellow");
x_iris_center_avg = (x_R_iris_center[0]+x_L_iris_center[0])/2;
y_iris_center_avg = (y_R_iris_center[0]+y_L_iris_center[0])/2;
selectImage(ID);  //make sure we still have the same image
makeLine(x_iris_center_avg-10, y_iris_center_avg-Vert_dystopia_iris_center/2, x_iris_center_avg-10, y_iris_center_avg+Vert_dystopia_iris_center/2);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "Vert Dystopia iris_centers");

x_lat_canth_avg = (x_R_lat_canth+x_L_lat_canth)/2;
y_lat_canth_avg = (y_R_lat_canth+y_L_lat_canth)/2;
selectImage(ID);  //make sure we still have the same image
makeLine(x_lat_canth_avg+10, y_lat_canth_avg-Vert_dystopia_lat/2, x_lat_canth_avg+10, y_lat_canth_avg+Vert_dystopia_lat/2);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "Vert Dystopia Lat Canth");



//Distances
ICD = x_L_med_canth-x_R_med_canth;
IPD = x_L_iris_center[0]-x_R_iris_center[0];
OCD = x_L_lat_canth-x_R_lat_canth; //lat (outer) canthal distance 
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_med_canth, y_R_med_canth, x_L_med_canth, y_L_med_canth);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "ICD");
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_iris_center[0], y_R_iris_center[0], x_L_iris_center[0], y_L_iris_center[0]);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "IPD");
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_lat_canth, y_R_lat_canth, x_L_lat_canth, y_L_lat_canth);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "OCD");


//Calculates via line segments between lines instead of with fit lines now
yfit_R_MBH = calc_Y(x_R_med_canth,x_R_eyebrow_bot,y_R_eyebrow_bot);
R_MBH = -yfit_R_MBH+y_R_med_canth;

yfit_R_LBH = calc_Y(x_R_lat_canth,x_R_eyebrow_bot,y_R_eyebrow_bot);
R_LBH = -yfit_R_LBH+y_R_lat_canth;

yfit_R_brow_bot_ML = calc_Y(x_R_med_limbus,x_R_eyebrow_bot,y_R_eyebrow_bot);
R_MLBH = -yfit_R_brow_bot_ML+y_R_iris_center[0];

yfit_R_brow_bot_LL = calc_Y(x_R_lat_limbus,x_R_eyebrow_bot,y_R_eyebrow_bot);
R_LLBH  = -yfit_R_brow_bot_LL+y_R_iris_center[0];

yfit_R_brow_bot_center = calc_Y(x_R_iris_center[0],x_R_eyebrow_bot,y_R_eyebrow_bot);
R_center_BH  = -yfit_R_brow_bot_center+y_R_iris_center[0];



//Calculates via line segments between lines instead of with fit lines now
yfit_L_MBH = calc_Y(x_L_med_canth,x_L_eyebrow_bot,y_L_eyebrow_bot);
L_MBH = -yfit_L_MBH+y_L_med_canth;

yfit_L_LBH = calc_Y(x_L_lat_canth,x_L_eyebrow_bot,y_L_eyebrow_bot);
L_LBH = -yfit_L_LBH+y_L_lat_canth;

yfit_L_brow_bot_ML = calc_Y(x_L_med_limbus,x_L_eyebrow_bot,y_L_eyebrow_bot);
L_MLBH = -yfit_L_brow_bot_ML+y_L_iris_center[0];

yfit_L_brow_bot_LL = calc_Y(x_L_lat_limbus,x_L_eyebrow_bot,y_L_eyebrow_bot);
L_LLBH  = -yfit_L_brow_bot_LL+y_L_iris_center[0];

yfit_L_brow_bot_center = calc_Y(x_L_iris_center[0],x_L_eyebrow_bot,y_L_eyebrow_bot);
L_center_BH  = -yfit_L_brow_bot_center+y_L_iris_center[0];



selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_med_canth, y_R_med_canth, x_R_med_canth, yfit_R_MBH);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R MBH");

selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_med_canth, y_L_med_canth, x_L_med_canth, yfit_L_MBH);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L MBH")

selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_med_limbus, y_R_iris_center[0], x_R_med_limbus, yfit_R_brow_bot_ML);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Medial Limbus BH");

selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_med_limbus, y_L_iris_center[0], x_L_med_limbus, yfit_L_brow_bot_ML);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Medial Limbus BH");

selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_iris_center[0], y_R_iris_center[0], x_R_iris_center[0], yfit_R_brow_bot_center);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Central BH");

selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_iris_center[0], y_L_iris_center[0], x_L_iris_center[0], yfit_L_brow_bot_center);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Central BH");

selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_lat_limbus, y_R_iris_center[0], x_R_lat_limbus, yfit_R_brow_bot_LL);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Lateral Limbus BH");

selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_lat_limbus, y_L_iris_center[0], x_L_lat_limbus, yfit_L_brow_bot_LL);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Lateral Limbus BH");

		makeLine(x_R_lat_canth, y_R_lat_canth, x_R_lat_canth, yfit_R_LBH);
	roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R LBH");

		makeLine(x_L_lat_canth, y_L_lat_canth, x_L_lat_canth, yfit_L_LBH);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L LBH");

//--------------------------------------------------------------------------
//Tarsal Platform Show and Brow Fat Span - disabled in current version


if(yes_R_lid_crease==1) {
/*
selectImage(ID);  //make sure we still have the same image
 Fit.doFit("4th Degree Polynomial", x_R_lid_crease, y_R_lid_crease);
    a_c = Fit.p(0);
	b_c = Fit.p(1);
	c_c = Fit.p(2);
	d_c = Fit.p(3);
	e_c = Fit.p(4);
		b_calc_c= b_c*x_R_iris_center[0];
		c_calc_c= c_c*x_R_iris_center[0]*x_R_iris_center[0];
		d_calc_c= d_c*x_R_iris_center[0]*x_R_iris_center[0]*x_R_iris_center[0];
		e_calc_c= e_c*x_R_iris_center[0]*x_R_iris_center[0]*x_R_iris_center[0]*x_R_iris_center[0]; //had to be done this way because otherwise
		yfit_R_lid_crease = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;

		b_calc_c= b_c*x_R_med_limbus;
		c_calc_c= c_c*x_R_med_limbus*x_R_med_limbus;
		d_calc_c= d_c*x_R_med_limbus*x_R_med_limbus*x_R_med_limbus;
		e_calc_c= e_c*x_R_med_limbus*x_R_med_limbus*x_R_med_limbus*x_R_med_limbus; //had to be done this way because otherwise
		yfit_R_lid_crease_ML = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
		
		b_calc_c= b_c*x_R_lat_limbus;
		c_calc_c= c_c*x_R_lat_limbus*x_R_lat_limbus;
		d_calc_c= d_c*x_R_lat_limbus*x_R_lat_limbus*x_R_lat_limbus;
		e_calc_c= e_c*x_R_lat_limbus*x_R_lat_limbus*x_R_lat_limbus*x_R_lat_limbus; //had to be done this way because otherwise
		yfit_R_lid_crease_LL = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
	
		b_calc_c= b_c*x_R_med_canth;
		c_calc_c= c_c*x_R_med_canth*x_R_med_canth;
		d_calc_c= d_c*x_R_med_canth*x_R_med_canth*x_R_med_canth;
		e_calc_c= e_c*x_R_med_canth*x_R_med_canth*x_R_med_canth*x_R_med_canth; //had to be done this way because otherwise
		yfit_R_lid_crease_med_canth = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
		
		b_calc_c= b_c*x_R_lat_canth;
		c_calc_c= c_c*x_R_lat_canth*x_R_lat_canth;
		d_calc_c= d_c*x_R_lat_canth*x_R_lat_canth*x_R_lat_canth;
		e_calc_c= e_c*x_R_lat_canth*x_R_lat_canth*x_R_lat_canth*x_R_lat_canth; //had to be done this way because otherwise
		yfit_R_lid_crease_lat_canth = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
*/
yfit_R_lid_crease = calc_Y(x_R_iris_center[0],x_R_lid_crease, y_R_lid_crease);
yfit_R_lid_crease_ML = calc_Y(x_R_med_limbus,x_R_lid_crease, y_R_lid_crease);
yfit_R_lid_crease_LL = calc_Y(x_R_lat_limbus,x_R_lid_crease, y_R_lid_crease);
yfit_R_lid_crease_upper_punc = calc_Y(x_R_upper_punc,x_R_lid_crease, y_R_lid_crease);
yfit_R_lid_crease_lat_canth = calc_Y(x_R_lat_canth,x_R_lid_crease, y_R_lid_crease);

}

if(yes_L_lid_crease==1) {
/*selectImage(ID);  //make sure we still have the same image
 Fit.doFit("4th Degree Polynomial", x_L_lid_crease, y_L_lid_crease);
    a_c = Fit.p(0);
	b_c = Fit.p(1);
	c_c = Fit.p(2);
	d_c = Fit.p(3);
	e_c = Fit.p(4);
		b_calc_c= b_c*x_L_iris_center[0];
		c_calc_c= c_c*x_L_iris_center[0]*x_L_iris_center[0];
		d_calc_c= d_c*x_L_iris_center[0]*x_L_iris_center[0]*x_L_iris_center[0];
		e_calc_c= e_c*x_L_iris_center[0]*x_L_iris_center[0]*x_L_iris_center[0]*x_L_iris_center[0]; //had to be done this way because otherwise
		yfit_L_lid_crease = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;

		b_calc_c= b_c*x_L_med_limbus;
		c_calc_c= c_c*x_L_med_limbus*x_L_med_limbus;
		d_calc_c= d_c*x_L_med_limbus*x_L_med_limbus*x_L_med_limbus;
		e_calc_c= e_c*x_L_med_limbus*x_L_med_limbus*x_L_med_limbus*x_L_med_limbus; //had to be done this way because otherwise
		yfit_L_lid_crease_ML = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
		
		b_calc_c= b_c*x_L_lat_limbus;
		c_calc_c= c_c*x_L_lat_limbus*x_L_lat_limbus;
		d_calc_c= d_c*x_L_lat_limbus*x_L_lat_limbus*x_L_lat_limbus;
		e_calc_c= e_c*x_L_lat_limbus*x_L_lat_limbus*x_L_lat_limbus*x_L_lat_limbus; //had to be done this way because otherwise
		yfit_L_lid_crease_LL = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
	
		b_calc_c= b_c*x_L_med_canth;
		c_calc_c= c_c*x_L_med_canth*x_L_med_canth;
		d_calc_c= d_c*x_L_med_canth*x_L_med_canth*x_L_med_canth;
		e_calc_c= e_c*x_L_med_canth*x_L_med_canth*x_L_med_canth*x_L_med_canth; //had to be done this way because otherwise
		yfit_L_lid_crease_med_canth = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
		
		b_calc_c= b_c*x_L_lat_canth;
		c_calc_c= c_c*x_L_lat_canth*x_L_lat_canth;
		d_calc_c= d_c*x_L_lat_canth*x_L_lat_canth*x_L_lat_canth;
		e_calc_c= e_c*x_L_lat_canth*x_L_lat_canth*x_L_lat_canth*x_L_lat_canth; //had to be done this way because otherwise
		yfit_L_lid_crease_lat_canth = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
*/
yfit_L_lid_crease = calc_Y(x_L_iris_center[0],x_L_lid_crease, y_L_lid_crease);
yfit_L_lid_crease_ML = calc_Y(x_L_med_limbus,x_L_lid_crease, y_L_lid_crease);
yfit_L_lid_crease_LL = calc_Y(x_L_lat_limbus,x_L_lid_crease, y_L_lid_crease);
yfit_L_lid_crease_upper_punc = calc_Y(x_L_upper_punc,x_L_lid_crease, y_L_lid_crease);
yfit_L_lid_crease_lat_canth = calc_Y(x_L_lat_canth,x_L_lid_crease, y_L_lid_crease);

		
}

TPS_R_ML = 0;
TPS_R_iris_center = 0;
TPS_R_LL = 0;
TPS_R_lat_canth = 0;
TPS_R_upper_punc = 0;
BFS_R_med_canth = R_MBH;
BFS_R_ML = R_MLBH;
BFS_R_iris_center = R_center_BH;
BFS_R_LL = R_LLBH;
BFS_R_lat_canth = R_LBH;

TPS_L_ML = 0;
TPS_L_iris_center = 0;
TPS_L_LL = 0;
TPS_L_lat_canth = 0;
TPS_L_upper_punc = 0;
BFS_L_med_canth = L_MBH;
BFS_L_ML = L_MLBH;
BFS_L_iris_center = L_center_BH;
BFS_L_LL = L_LLBH;
BFS_L_lat_canth = L_LBH;


if(yes_R_lid_crease==1) {
//x_val = x_R_med_canth;
//if(x_val>x_R_lid_creasemin){
//if(x_val<x_R_lid_creasemax){

TPS_R_upper_punc = y_R_med_canth-yfit_R_lid_crease_upper_punc;
BFS_R_med_canth = y_R_upper_punc-yfit_R_MBH;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_upper_punc, y_R_upper_punc, x_R_upper_punc, yfit_R_lid_crease_upper_punc);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R TPS Med Canth");
roiManager("Set Color", "magenta");
/*selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_med_canth, yfit_R_lid_crease_med_canth, x_R_med_canth, yfit_R_MBH);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R BFS Med Limbus")
*/
//}}

//x_val = x_R_med_limbus;
//if(x_val>x_R_lid_creasemin){
//if(x_val<x_R_lid_creasemax){

TPS_R_ML = yfit_R_upper_lid_ML-yfit_R_lid_crease_ML;
BFS_R_ML = yfit_R_lid_crease_ML - yfit_R_brow_bot_ML;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_med_limbus, yfit_R_upper_lid_ML, x_R_med_limbus, yfit_R_lid_crease_ML);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R TPS Med Limbus");
roiManager("Set Color", "magenta");
/*selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_med_limbus, yfit_R_lid_crease_ML, x_R_med_limbus, yfit_R_brow_bot_ML);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R BFS Med Limbus")*/
//}}

//x_val = x_R_iris_center[0];
//if(x_val>x_R_lid_creasemin){
//if(x_val<x_R_lid_creasemax){
TPS_R_iris_center = yfit_R_upper_lid-yfit_R_lid_crease;
BFS_R_iris_center = yfit_R_lid_crease - yfit_R_brow_bot_center;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_iris_center[0], yfit_R_upper_lid, x_R_iris_center[0], yfit_R_lid_crease);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R TPS Iris Center");
roiManager("Set Color", "magenta");
/*selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_iris_center[0], yfit_R_lid_crease, x_R_iris_center[0], yfit_R_brow_bot_center);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R BFS Iris Center")*/
//}}

//x_val = x_R_iris_center[0];
//if(x_val>x_R_lid_creasemin){
//if(x_val<x_R_lid_creasemax){
TPS_R_LL = yfit_R_upper_lid_LL-yfit_R_lid_crease_LL;
BFS_R_LL = yfit_R_lid_crease_LL - yfit_R_brow_bot_LL;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_lat_limbus, yfit_R_upper_lid_LL, x_R_lat_limbus, yfit_R_lid_crease_LL);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R TPS Lat Limbus");
roiManager("Set Color", "magenta");
/*
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_lat_limbus,  yfit_R_lid_crease_LL, x_R_lat_limbus, yfit_R_brow_bot_LL);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R BFS Lat Limbus")*/
//}}

//x_val = x_R_lat_canth;
//if(x_val>x_R_lid_creasemin){
//if(x_val<x_R_lid_creasemax){
TPS_R_lat_canth = y_R_lat_canth-yfit_R_lid_crease_lat_canth;
BFS_R_lat_canth = yfit_R_lid_crease_lat_canth-yfit_R_LBH;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_lat_canth, y_R_lat_canth, x_R_lat_canth, yfit_R_lid_crease_lat_canth);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R TPS Lat Canth");
roiManager("Set Color", "magenta");
/*
selectImage(ID);  //make sure we still have the same image
		makeLine(x_R_lat_canth, yfit_R_lid_crease_lat_canth, x_R_lat_canth, yfit_R_MBH);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R BFS Lat Limbus")*/
//}}
}



if(yes_L_lid_crease==1) {
//x_val = x_L_med_canth;
//if(x_val>x_L_lid_creasemin){
//if(x_val<x_L_lid_creasemax){




TPS_L_upper_punc = y_L_med_canth-yfit_L_lid_crease_upper_punc;
BFS_L_med_canth = y_L_upper_punc-yfit_L_MBH;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_upper_punc, y_L_upper_punc, x_L_upper_punc, yfit_L_lid_crease_upper_punc);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L TPS Med Canth");
roiManager("Set Color", "magenta");
/*
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_med_canth, yfit_L_lid_crease_med_canth, x_L_med_canth, yfit_L_MBH);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L BFS Med Limbus")*/
//}}

//x_val = x_L_med_limbus;
//if(x_val>x_L_lid_creasemin){
//if(x_val<x_L_lid_creasemax){
TPS_L_ML = yfit_L_upper_lid_ML-yfit_L_lid_crease_ML;
BFS_L_ML = yfit_L_lid_crease_ML - yfit_L_brow_bot_ML;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_med_limbus, yfit_L_upper_lid_ML, x_L_med_limbus, yfit_L_lid_crease_ML);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L TPS Med Limbus");
roiManager("Set Color", "magenta");

/*selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_med_limbus, yfit_L_lid_crease_ML, x_L_med_limbus, yfit_L_brow_bot_ML);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L BFS Med Limbus")*/
//}}

//x_val = x_L_iris_center[0];
//if(x_val>x_L_lid_creasemin){
//if(x_val<x_L_lid_creasemax){
TPS_L_iris_center = yfit_L_upper_lid-yfit_L_lid_crease;
BFS_L_iris_center = yfit_L_lid_crease - yfit_L_brow_bot_center;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_iris_center[0], yfit_L_upper_lid, x_L_iris_center[0], yfit_L_lid_crease);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L TPS Iris Center");
roiManager("Set Color", "magenta");
/*
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_iris_center[0], yfit_L_lid_crease, x_L_iris_center[0], yfit_L_brow_bot_center);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L _L_ Iris Center")*/
//}}

//x_val = x_L_iris_center[0];
//if(x_val>x_L_lid_creasemin){
//if(x_val<x_L_lid_creasemax){
TPS_L_LL = yfit_L_upper_lid_LL-yfit_L_lid_crease_LL;
_L__L_LL = yfit_L_lid_crease_LL - yfit_L_brow_bot_LL;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_lat_limbus, yfit_L_upper_lid_LL, x_L_lat_limbus, yfit_L_lid_crease_LL);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L TPS Lat Limbus");
roiManager("Set Color", "magenta");
/*
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_lat_limbus,  yfit_L_lid_crease_LL, x_L_lat_limbus, yfit_L_brow_bot_LL);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L BFS Lat Limbus")*/
//}}

//x_val = x_L_lat_canth;
//if(x_val>x_L_lid_creasemin){
//if(x_val<x_L_lid_creasemax){
TPS_L_lat_canth = y_L_lat_canth-yfit_L_lid_crease_lat_canth;
BFS_L_lat_canth = yfit_L_lid_crease_lat_canth-yfit_L_LBH;
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_lat_canth, y_L_lat_canth, x_L_lat_canth, yfit_L_lid_crease_lat_canth);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L TPS Lat Canth");
roiManager("Set Color", "magenta");
/*
selectImage(ID);  //make sure we still have the same image
		makeLine(x_L_lat_canth, yfit_L_lid_crease_lat_canth, x_L_lat_canth, yfit_L_MBH);
		roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L BFS Lat Limbus")*/
//}}
}




//This section draws all the 4th degree polynomial best-fit lines for the various features
//setTool("multipoint");
makePoint(1000000, 1000000, "small yellow hybrid");
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "Best-fit:");

fitline_4th_deg(x_R_eyebrow_top,y_R_eyebrow_top);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Superior Brow Best-Fit");
roiManager("Set Color", "cyan");
fitline_4th_deg(x_R_eyebrow_bot,y_R_eyebrow_bot);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Inferior Brow Best-Fit");
roiManager("Set Color", "cyan");
	if(yes_R_lid_crease==1) {
fitline_4th_deg(x_R_lid_crease, y_R_lid_crease);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Lid Crease Best-Fit");}
roiManager("Set Color", "cyan");
fitline_4th_deg(x_R_upper_lid,y_R_upper_lid);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Upper Lid Best-Fit");
roiManager("Set Color", "cyan");
fitline_4th_deg(x_R_lower_lid,y_R_lower_lid);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "R Lower Lid Best-Fit");
roiManager("Set Color", "cyan");

fitline_4th_deg(x_L_eyebrow_top,y_L_eyebrow_top);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Superior Brow Best-Fit");
roiManager("Set Color", "cyan");
fitline_4th_deg(x_L_eyebrow_bot,y_L_eyebrow_bot);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Inferior Brow Best-Fit");
roiManager("Set Color", "cyan");

	if(yes_L_lid_crease==1) {
fitline_4th_deg(x_L_lid_crease, y_L_lid_crease);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Lid Crease Best-Fit");}
roiManager("Set Color", "cyan");
fitline_4th_deg(x_L_upper_lid,y_L_upper_lid);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Upper Lid Best-Fit");
roiManager("Set Color", "cyan");
fitline_4th_deg(x_L_lower_lid,y_L_lower_lid);
roiManager("Add");
roi_idx = roi_idx+1;
roiManager("Select", roi_idx);
roiManager("Rename", "L Lower Lid Best-Fit");
roiManager("Set Color", "cyan");
run("Select None");

//--------------------------------------------------------
//------------Show results---------------------
//---------------------------------------------------------------

//https://forum.image.sc/t/creating-custom-tables-in-imagej/33100
//Table.create("table1");
//run("Clear Results");

//run("Set Scale...", "distance="+iris_dia_avg+" known=11.7 unit=mm");

rotation = getValue("rotation.angle");



path = getDirectory("image");
folderName = File.getName(path); //This is the FOLDER where the image is held
    	
imageName = getTitle(); //***Will need to be updated to folder name
imageName = substring(imageName,0,lengthOf(imageName)-4); //lops off the extension part of the name
folder_path = File.getParent(path);
backslash_index = lastIndexOf(folder_path, File.separator);
//print("Index: "+backslash_index);
folder_parent_name = substring(folder_path, backslash_index+1,lengthOf(folder_path)); //This is the PARENT folder
parentofparentpath = substring(folder_path, 0, backslash_index);
//print("Parent of parent: "+parentofparentpath);
parentofparent_index = lastIndexOf(parentofparentpath, File.separator);
parentofparent_folder = substring(parentofparentpath, parentofparent_index+1, parentofparentpath.length); //This is the PARENT OF PARENT folder. Currently not being used in the code.

path_new_folder= path+imageName+"_Data"; 



    getDateAndTime(year2, month2, dayOfWeek2, dayOfMonth2, hour2, minute2, second2, msec2);
    if (hour2<hour){
    	hour2=24+hour2; //This corrects for an error that would otherwise occur if user working through midnight. Adds 24 hours if goes from 23 to 0 hrs
    	}
    	hour_diff = hour2-hour;
    	minute_diff = minute2-minute;
    	second_diff = second2-second;
    	second_elapsed = hour_diff*3600+minute_diff*60+second_diff;
    	minute_elapsed = second_elapsed/60;


//Uncomment this section if you want tarsal plate show and brow fat span measurements
/*
periorbit_measures = newArray(folder_parent_name,folderName,imageName,minute_elapsed,second_elapsed,rotation,
R_MRD1,R_MRD2,R_PFH,R_PFW,L_MRD1,L_MRD2,L_PFH,L_PFW,
R_sup_scleral_show,R_inf_scleral_show,L_sup_scleral_show,
L_inf_scleral_show,R_canthal_tilt,L_canthal_tilt,R_iris_dia[0],L_iris_dia[0],iris_dia_avg,
R_pupil_dia[0],L_pupil_dia[0],pupil_dia_avg,Vert_dystopia_med,Vert_dystopia_iris_center,Vert_dystopia_lat,ICD,IPD,OCD,
R_MBH,L_MBH,R_MLBH,L_MLBH,R_center_BH,L_center_BH,R_LLBH,L_LLBH,R_LBH,L_LBH,
TPS_R_upper_punc,TPS_L_upper_punc,TPS_R_ML,TPS_L_ML,TPS_R_iris_center,TPS_L_iris_center,TPS_R_LL,TPS_L_LL,TPS_R_lat_canth,TPS_L_lat_canth,
BFS_R_med_canth,BFS_L_med_canth,BFS_R_ML,BFS_L_ML,BFS_R_iris_center,BFS_L_iris_center,BFS_R_LL,BFS_L_LL,BFS_R_lat_canth,BFS_L_lat_canth
);
periorbit_measures_scaled = newArray(periorbit_measures.length);
periorbit_measures_labels = newArray("Parent Folder","Folder","Image","Elapsed Time (min)","Elapsed Time (s)","Rotation",
"R_MRD1","R_MRD2","R_PFH","R_PFW","L_MRD1","L_MRD2","L_PFH","L_PFW",
"R_sup_scleral_show","R_inf_scleral_show",
"L_sup_scleral_show","L_inf_scleral_show","R_canthal_tilt(deg)","L_canthal_tilt(deg)","R_iris_dia(pixels)","L_iris_dia(pixels)","iris_dia_avg(pixels)",
"R_pupil_dia","L_pupil_dia","pupil_dia_avg","Vert_dystopia_med","Vert_dystopia_iris_center",
"Vert_dystopia_lat","ICD","IPD","OCD",
"R_MBH","L_MBH","R_MLBH","L_MLBH","R_center_BH","L_center_BH","R_LLBH","L_LLBH","R_LBH","L_LBH",
"TPS_R_upper_punc","TPS_L_upper_punc","TPS_R_ML","TPS_L_ML","TPS_R_iris_center","TPS_L_iris_center","TPS_R_LL","TPS_L_LL","TPS_R_lat_canth","TPS_L_lat_canth",
"BFS_R_med_canth","BFS_L_med_canth","BFS_R_ML","BFS_L_ML","BFS_R_iris_center","BFS_L_iris_center","BFS_R_LL","BFS_L_LL","BFS_R_lat_canth","BFS_L_lat_canth"
);*/

//This section has TPS but no BFS
/*
periorbit_measures = newArray(folder_parent_name,folderName,imageName,minute_elapsed,second_elapsed,rotation,
R_MRD1,R_MRD2,R_PFH,R_PFW,L_MRD1,L_MRD2,L_PFH,L_PFW,
R_sup_scleral_show,R_inf_scleral_show,L_sup_scleral_show,
L_inf_scleral_show,R_canthal_tilt,L_canthal_tilt,R_iris_dia[0],L_iris_dia[0],iris_dia_avg,
R_pupil_dia[0],L_pupil_dia[0],pupil_dia_avg,Vert_dystopia_med,Vert_dystopia_iris_center,Vert_dystopia_lat,ICD,IPD,OCD,
R_MBH,L_MBH,R_MLBH,L_MLBH,R_center_BH,L_center_BH,R_LLBH,L_LLBH,R_LBH,L_LBH,
TPS_R_upper_punc,TPS_L_upper_punc,TPS_R_ML,TPS_L_ML,TPS_R_iris_center,TPS_L_iris_center,TPS_R_LL,TPS_L_LL,TPS_R_lat_canth,TPS_L_lat_canth
);
periorbit_measures_scaled = newArray(periorbit_measures.length);
periorbit_measures_labels = newArray("Parent Folder","Folder","Image","Elapsed Time (min)","Elapsed Time (s)","Rotation",
"R_MRD1","R_MRD2","R_PFH","R_PFW","L_MRD1","L_MRD2","L_PFH","L_PFW",
"R_sup_scleral_show","R_inf_scleral_show",
"L_sup_scleral_show","L_inf_scleral_show","R_canthal_tilt(deg)","L_canthal_tilt(deg)","R_iris_dia(pixels)","L_iris_dia(pixels)","iris_dia_avg(pixels)",
"R_pupil_dia","L_pupil_dia","pupil_dia_avg","Vert_dystopia_med","Vert_dystopia_iris_center",
"Vert_dystopia_lat","ICD","IPD","OCD",
"R_MBH","L_MBH","R_MLBH","L_MLBH","R_center_BH","L_center_BH","R_LLBH","L_LLBH","R_LBH","L_LBH",
"TPS_R_upper_punc","TPS_L_upper_punc","TPS_R_ML","TPS_L_ML","TPS_R_iris_center","TPS_L_iris_center","TPS_R_LL","TPS_L_LL","TPS_R_lat_canth","TPS_L_lat_canth"
);
*/

//This section has NO TPS, no BFS, and no pupil, +image date, filepath
periorbit_measures = newArray(DateString,path,imageName,minute_elapsed,second_elapsed,rotation,
R_MRD1,R_MRD2,R_PFH,R_PFW,L_MRD1,L_MRD2,L_PFH,L_PFW,
R_sup_scleral_show,R_inf_scleral_show,L_sup_scleral_show,
L_inf_scleral_show,R_canthal_tilt,L_canthal_tilt,R_iris_dia[0],L_iris_dia[0],iris_dia_avg,
Vert_dystopia_med,Vert_dystopia_iris_center,Vert_dystopia_lat,ICD,IPD,OCD,
R_MBH,L_MBH,R_MLBH,L_MLBH,R_center_BH,L_center_BH,R_LLBH,L_LLBH,R_LBH,L_LBH);
periorbit_measures_scaled = newArray(periorbit_measures.length);
periorbit_measures_labels = newArray("Measurement Date","File path","Image","Elapsed Time (min)","Elapsed Time (s)","Rotation",
"R_MRD1","R_MRD2","R_PFH","R_PFW","L_MRD1","L_MRD2","L_PFH","L_PFW",
"R_sup_scleral_show","R_inf_scleral_show",
"L_sup_scleral_show","L_inf_scleral_show","R_canthal_tilt(deg)","L_canthal_tilt(deg)","R_iris_dia(pixels)","L_iris_dia(pixels)","iris_dia_avg(pixels)",
"Vert_dystopia_med","Vert_dystopia_iris_center",
"Vert_dystopia_lat","ICD","IPD","OCD",
"R_MBH","L_MBH","R_MLBH","L_MLBH","R_center_BH","L_center_BH","R_LLBH","L_LLBH","R_LBH","L_LBH"
);


//Comment this section and uncomment the section above if you want tarsal plate show and brow fat span measurements
/*
periorbit_measures = newArray(folder_parent_name,folderName,imageName,minute_elapsed,second_elapsed,rotation,
R_MRD1,R_MRD2,R_PFH,R_PFW,L_MRD1,L_MRD2,L_PFH,L_PFW,
R_sup_scleral_show,R_inf_scleral_show,L_sup_scleral_show,
L_inf_scleral_show,R_canthal_tilt,L_canthal_tilt,R_iris_dia[0],L_iris_dia[0],iris_dia_avg,
R_pupil_dia[0],L_pupil_dia[0],pupil_dia_avg,Vert_dystopia_med,Vert_dystopia_iris_center,Vert_dystopia_lat,ICD,IPD,OCD,
R_MBH,L_MBH,R_MLBH,L_MLBH,R_center_BH,L_center_BH,R_LLBH,L_LLBH,R_LBH,L_LBH
);
periorbit_measures_scaled = newArray(periorbit_measures.length);
periorbit_measures_labels = newArray("Parent Folder","Folder","Image","Elapsed Time (min)","Elapsed Time (s)","Rotation",
"R_MRD1","R_MRD2","R_PFH","R_PFW","L_MRD1","L_MRD2","L_PFH","L_PFW",
"R_sup_scleral_show","R_inf_scleral_show",
"L_sup_scleral_show","L_inf_scleral_show","R_canthal_tilt(deg)","L_canthal_tilt(deg)","R_iris_dia(pixels)","L_iris_dia(pixels)","iris_dia_avg(pixels)",
"R_pupil_dia","L_pupil_dia","pupil_dia_avg","Vert_dystopia_med","Vert_dystopia_iris_center",
"Vert_dystopia_lat","ICD","IPD","OCD",
"R_MBH","L_MBH","R_MLBH","L_MLBH","R_center_BH","L_center_BH","R_LLBH","L_LLBH","R_LBH","L_LBH");

*/

print("periorbit_measures length:");
print(periorbit_measures.length);
print("periorbit_measures length:");
print(periorbit_measures_labels.length);

	

//Array.print(test2);
for(i=0;i<periorbit_measures_labels.length;i++){
	if(periorbit_measures_labels[i]=="R_canthal_tilt(deg)"){
periorbit_measures[i] = periorbit_measures[i];
print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="L_canthal_tilt(deg)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="R_iris_dia(pixels)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="L_iris_dia(pixels)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="iris_dia_avg(pixels)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="Image"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="Folder"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");		
		}else if(periorbit_measures_labels[i]=="Parent Folder"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");	
		}else if(periorbit_measures_labels[i]=="Elapsed Time (min)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");	
		}else if(periorbit_measures_labels[i]=="Elapsed Time (s)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");		
		}else if(periorbit_measures_labels[i]=="angle_R_lat_canth(deg)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="angle_L_med_canth(deg)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="angle_L_lat_canth(deg)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="Rotation"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
		}else if(periorbit_measures_labels[i]=="angle_L_med_canth(deg)"){
	periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
	}else if(periorbit_measures_labels[i]=="Measurement Date"){
			periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");
	}else if(periorbit_measures_labels[i]=="File path"){
			periorbit_measures[i] = periorbit_measures[i];
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+". Did not scale value here!");	
		}else if(periorbit_measures_labels[i]=="R_MRD1"){
		periorbit_measures[i] = periorbit_measures[i]*(11.7/iris_dia_avg); //scales but doesn't do abs value since you can have neg MRD 
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+".");
		}else if(periorbit_measures_labels[i]=="L_MRD1"){
		periorbit_measures[i] = periorbit_measures[i]*(11.7/iris_dia_avg); //scales but doesn't do abs value since you can have neg MRD 
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+".");
		}else if(periorbit_measures_labels[i]=="R_MRD2"){
		periorbit_measures[i] = periorbit_measures[i]*(11.7/iris_dia_avg); 
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+".");
		}else if(periorbit_measures_labels[i]=="L_MRD2"){
		periorbit_measures[i] = periorbit_measures[i]*(11.7/iris_dia_avg);
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+".");
		}else if(periorbit_measures_labels[i]=="R_PFH"){
		periorbit_measures[i] = periorbit_measures[i]*(11.7/iris_dia_avg);
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+".");
		}else if(periorbit_measures_labels[i]=="L_PFH"){
		periorbit_measures[i] = periorbit_measures[i]*(11.7/iris_dia_avg);
	print("At i="+i+" label was:"+periorbit_measures_labels[i]+", and value was:"+periorbit_measures[i]+".");
		}else{
		periorbit_measures[i] = abs(periorbit_measures[i]*(11.7/iris_dia_avg)); //this scales all the values to the average iris diameter of 11.7mm
	}
}


for (i=0; i<periorbit_measures_labels.length;i++){
	setResult(periorbit_measures_labels[i], 0, periorbit_measures[i]);
}
updateResults();

//Concatenate upper and lower lids from medial to lateral canthus
x_R_upper_lid_med_to_lat_canth = Array.concat(x_R_upper_med_canth,x_R_upper_lid);
y_R_upper_lid_med_to_lat_canth = Array.concat(y_R_upper_med_canth,y_R_upper_lid);

x_R_lower_lid_med_to_lat_canth = Array.concat(x_R_lower_med_canth,x_R_lower_lid);
y_R_lower_lid_med_to_lat_canth = Array.concat(y_R_lower_med_canth,y_R_lower_lid);


x_L_upper_lid_med_to_lat_canth = Array.concat(x_L_upper_med_canth,x_L_upper_lid);
y_L_upper_lid_med_to_lat_canth = Array.concat(y_L_upper_med_canth,y_L_upper_lid);

x_L_lower_lid_med_to_lat_canth = Array.concat(x_L_lower_med_canth,x_L_lower_lid);
y_L_lower_lid_med_to_lat_canth = Array.concat(y_L_lower_med_canth,y_L_lower_lid);

//Now removed pupils 
x_landmarks = newArray(x_R_iris_center[0],x_L_iris_center[0],x_R_med_canth,x_L_med_canth,x_R_med_limbus,x_L_med_limbus,
x_R_lat_limbus,x_L_lat_limbus,x_R_lat_canth,x_L_lat_canth,x_R_upper_punc,x_L_upper_punc);
y_landmarks = newArray(y_R_iris_center[0],y_L_iris_center[0],y_R_med_canth,y_L_med_canth,y_R_iris_center[0]
,y_L_iris_center[0],y_R_iris_center[0],y_L_iris_center[0],y_R_lat_canth,y_L_lat_canth,y_R_upper_punc,y_L_upper_punc);


landmarks_label = newArray("R_iris_center","L_iris_center","R_med_canth","L_med_canth",
"R_med_limbus","L_med_limbus","R_lat_limbus","L_lat_limbus","R_lat_canth","y_L_lat_canth","R_upper_punct","L_upper_punct");
_ = newArray("");
__ = newArray("Moved to ref point");
imagename = newArray(imageName);
foldername = newArray(folderName);
parentfoldername = newArray(folder_parent_name);

Array.show( "XY Coordinates",parentfoldername,foldername,imagename,landmarks_label,x_landmarks,y_landmarks,
_,
x_R_eyebrow_top, y_R_eyebrow_top, 
x_R_eyebrow_bot, y_R_eyebrow_bot,
x_R_lid_crease, y_R_lid_crease, 
x_R_upper_med_canth,y_R_upper_med_canth,
x_R_upper_lid,y_R_upper_lid,
x_R_upper_lid_med_to_lat_canth,y_R_upper_lid_med_to_lat_canth,
x_R_lower_med_canth,y_R_lower_med_canth,
x_R_lower_lid,y_R_lower_lid,
x_R_lower_lid_med_to_lat_canth,y_R_lower_lid_med_to_lat_canth,
x_L_eyebrow_top, y_L_eyebrow_top,
x_L_eyebrow_bot, y_L_eyebrow_bot,
x_L_lid_crease, y_L_lid_crease,
x_L_upper_med_canth,y_L_upper_med_canth,
x_L_upper_lid,y_L_upper_lid,
x_L_upper_lid_med_to_lat_canth,y_L_upper_lid_med_to_lat_canth,
x_L_lower_med_canth,y_L_lower_med_canth,
x_L_lower_lid,y_L_lower_lid,
x_L_lower_lid_med_to_lat_canth,y_L_lower_lid_med_to_lat_canth);




run("Set Scale...", "distance="+iris_dia_avg+" known=11.7 unit=mm"); //sets iris diameter to standard 11.7mm
//which will be used to convert all the pixel coordinate values below to mm. Note that in pixels, the origin
//is 0,0 at the TOP LEFT corner. After conversion, the origin flips to the BOTTOM LEFT corner
//i.e. the y-values flip 

toScaled( x_R_eyebrow_top, y_R_eyebrow_top); 
toScaled( x_R_eyebrow_bot, y_R_eyebrow_bot );
if(yes_R_lid_crease==1) {
toScaled( x_R_lid_crease, y_R_lid_crease );
toScaled( x_L_lid_crease, y_L_lid_crease );
}
toScaled( x_R_upper_lid, y_R_upper_lid );
toScaled( x_R_lower_lid, y_R_lower_lid );
toScaled( x_L_eyebrow_top, y_L_eyebrow_top );
toScaled( x_L_eyebrow_bot, y_L_eyebrow_bot );
toScaled( x_L_upper_lid, y_L_upper_lid );
toScaled( x_L_lower_lid, y_L_lower_lid );
toScaled(x_R_upper_med_canth,y_R_upper_med_canth);
toScaled(x_R_upper_lid_med_to_lat_canth,y_R_upper_lid_med_to_lat_canth);
toScaled(x_R_lower_med_canth,y_R_lower_med_canth);
toScaled(x_R_lower_lid_med_to_lat_canth,y_R_lower_lid_med_to_lat_canth);
toScaled(x_L_upper_med_canth,y_L_upper_med_canth);
toScaled(x_L_upper_lid_med_to_lat_canth,y_L_upper_lid_med_to_lat_canth);
toScaled(x_L_lower_med_canth,y_L_lower_med_canth);
toScaled(x_L_lower_lid_med_to_lat_canth,y_L_lower_lid_med_to_lat_canth);


//----------Stats scaled to milimeters---------
Array.getStatistics(x_R_eyebrow_top, x_R_eyebrow_topmin, x_R_eyebrow_topmax,x_R_eyebrow_topmean,x_R_eyebrow_topstd);
Array.getStatistics(y_R_eyebrow_top, y_R_eyebrow_topmin, y_R_eyebrow_topmax,y_R_eyebrow_topmean,y_R_eyebrow_topstd);
Array.getStatistics(x_R_eyebrow_bot, x_R_eyebrow_botmin, x_R_eyebrow_botmax,x_R_eyebrow_botmean,x_R_eyebrow_botstd);
Array.getStatistics(y_R_eyebrow_bot, y_R_eyebrow_botmin, y_R_eyebrow_botmax,y_R_eyebrow_botmean,y_R_eyebrow_botstd);
Array.getStatistics(x_R_lid_crease, x_R_lid_creasemin, x_R_lid_creasemax, x_R_lid_creasemean,x_R_lid_creasestd);
Array.getStatistics(y_R_lid_crease, y_R_lid_creasemin, y_R_lid_creasemax, y_R_lid_creasemean,y_R_lid_creasestd);
Array.getStatistics(x_R_upper_lid, x_R_upper_lidmin, x_R_upper_lidmax, x_R_upper_lidmean, x_R_upper_lidstd);
Array.getStatistics(y_R_upper_lid, y_R_upper_lidmin, y_R_upper_lidmax, y_R_upper_lidmean, y_R_upper_lidstd);
Array.getStatistics(x_R_lower_lid, x_R_lower_lidmin, x_R_lower_lidmax, x_R_lower_lidmean, x_R_lower_lidstd);
Array.getStatistics(y_R_lower_lid, y_R_lower_lidmin, y_R_lower_lidmax, y_R_lower_lidmean, y_R_lower_lidstd);
Array.getStatistics(x_L_eyebrow_top, x_L_eyebrow_topmin, x_L_eyebrow_topmax, x_L_eyebrow_topmean, x_L_eyebrow_topstd);
Array.getStatistics(y_L_eyebrow_top, y_L_eyebrow_topmin, y_L_eyebrow_topmax, y_L_eyebrow_topmean, y_L_eyebrow_topstd);
Array.getStatistics(x_L_eyebrow_bot, x_L_eyebrow_botmin, x_L_eyebrow_botmax, x_L_eyebrow_botmean, x_L_eyebrow_botstd);
Array.getStatistics(y_L_eyebrow_bot, y_L_eyebrow_botmin, y_L_eyebrow_botmax, y_L_eyebrow_botmean, y_L_eyebrow_botstd);
Array.getStatistics(x_L_lid_crease, x_L_lid_creasemin, x_L_lid_creasemax, x_L_lid_creasemean, x_L_lid_creasestd);
Array.getStatistics(y_L_lid_crease, y_L_lid_creasemin, y_L_lid_creasemax, y_L_lid_creasemean, y_L_lid_creasestd);
Array.getStatistics(x_L_upper_lid, x_L_upper_lidmin, x_L_upper_lidmax, x_L_upper_lidmean, x_L_upper_lidstd);
Array.getStatistics(y_L_upper_lid, y_L_upper_lidmin, y_L_upper_lidmax, y_L_upper_lidmean, y_L_upper_lidstd);
Array.getStatistics(x_L_lower_lid, x_L_lower_lidmin, x_L_lower_lidmax, x_L_lower_lidmean, x_L_lower_lidstd);
Array.getStatistics(y_L_lower_lid, y_L_lower_lidmin, y_L_lower_lidmax, y_L_lower_lidmean, y_L_lower_lidstd);

Array.getStatistics(x_R_upper_med_canth,x_R_upper_med_canthmin, x_R_upper_med_canthmax,x_R_upper_med_canthmean,x_R_upper_med_canthstd);	
Array.getStatistics(y_R_upper_med_canth,y_R_upper_med_canthmin, y_R_upper_med_canthmax,y_R_upper_med_canthmean,y_R_upper_med_canthstd);
Array.getStatistics(x_R_upper_lid_med_to_lat_canth,x_R_upper_lid_med_to_lat_canthmin, x_R_upper_lid_med_to_lat_canthmax,
x_R_upper_lid_med_to_lat_canthmean,x_R_upper_lid_med_to_lat_canthstd);	
Array.getStatistics(y_R_upper_lid_med_to_lat_canth,y_R_upper_lid_med_to_lat_canthmin, y_R_upper_lid_med_to_lat_canthmax,
y_R_upper_lid_med_to_lat_canthmean,y_R_upper_lid_med_to_lat_canthstd);
Array.getStatistics(x_R_lower_med_canth,x_R_lower_med_canthmin, x_R_lower_med_canthmax,x_R_lower_med_canthmean,x_R_lower_med_canthstd);	
Array.getStatistics(y_R_lower_med_canth,y_R_lower_med_canthmin, y_R_lower_med_canthmax,y_R_lower_med_canthmean,y_R_lower_med_canthstd);
Array.getStatistics(x_R_lower_lid_med_to_lat_canth,x_R_lower_lid_med_to_lat_canthmin, x_R_lower_lid_med_to_lat_canthmax,
x_R_lower_lid_med_to_lat_canthmean,x_R_lower_lid_med_to_lat_canthstd);	
Array.getStatistics(y_R_lower_lid_med_to_lat_canth,y_R_lower_lid_med_to_lat_canthmin, y_R_lower_lid_med_to_lat_canthmax,
y_R_lower_lid_med_to_lat_canthmean,y_R_lower_lid_med_to_lat_canthstd);
Array.getStatistics(x_L_upper_med_canth,x_L_upper_med_canthmin, x_L_upper_med_canthmax,x_L_upper_med_canthmean,x_L_upper_med_canthstd);	
Array.getStatistics(y_L_upper_med_canth,y_L_upper_med_canthmin, y_L_upper_med_canthmax,y_L_upper_med_canthmean,y_L_upper_med_canthstd);
Array.getStatistics(x_L_upper_lid_med_to_lat_canth,x_L_upper_lid_med_to_lat_canthmin, x_L_upper_lid_med_to_lat_canthmax,
x_L_upper_lid_med_to_lat_canthmean,x_L_upper_lid_med_to_lat_canthstd);	
Array.getStatistics(y_L_upper_lid_med_to_lat_canth,y_L_upper_lid_med_to_lat_canthmin, y_L_upper_lid_med_to_lat_canthmax,
y_L_upper_lid_med_to_lat_canthmean,y_L_upper_lid_med_to_lat_canthstd);
Array.getStatistics(x_L_lower_med_canth,x_L_lower_med_canthmin, x_L_lower_med_canthmax,x_L_lower_med_canthmean,x_L_lower_med_canthstd);	
Array.getStatistics(y_L_lower_med_canth,y_L_lower_med_canthmin, y_L_lower_med_canthmax,y_L_lower_med_canthmean,y_L_lower_med_canthstd);
Array.getStatistics(x_L_lower_lid_med_to_lat_canth,x_L_lower_lid_med_to_lat_canthmin, x_L_lower_lid_med_to_lat_canthmax,
x_L_lower_lid_med_to_lat_canthmean,x_L_lower_lid_med_to_lat_canthstd);	
Array.getStatistics(y_L_lower_lid_med_to_lat_canth,y_L_lower_lid_med_to_lat_canthmin, y_L_lower_lid_med_to_lat_canthmax,
y_L_lower_lid_med_to_lat_canthmean,y_L_lower_lid_med_to_lat_canthstd);

//Not including the canthal values in this because those tend to mess up the lid curve data, hence having it be
//separately selected in the beginning. 


x_R_eyebrow_top_ref = Array.copy(x_R_eyebrow_top);
y_R_eyebrow_top_ref = Array.copy(y_R_eyebrow_top);
x_R_eyebrow_bot_ref = Array.copy(x_R_eyebrow_bot);
y_R_eyebrow_bot_ref = Array.copy(y_R_eyebrow_bot);
x_R_lid_crease_ref = Array.copy(x_R_lid_crease);
y_R_lid_crease_ref = Array.copy(y_R_lid_crease);
x_R_upper_lid_ref = Array.copy(x_R_upper_lid);
y_R_upper_lid_ref = Array.copy(y_R_upper_lid);
x_R_lower_lid_ref = Array.copy(x_R_lower_lid);
y_R_lower_lid_ref = Array.copy(y_R_lower_lid);
x_L_eyebrow_top_ref = Array.copy(x_L_eyebrow_top);
y_L_eyebrow_top_ref = Array.copy(y_L_eyebrow_top);
x_L_eyebrow_bot_ref = Array.copy(x_L_eyebrow_bot);
y_L_eyebrow_bot_ref = Array.copy(y_L_eyebrow_bot);
x_L_lid_crease_ref = Array.copy(x_L_lid_crease);
y_L_lid_crease_ref = Array.copy(y_L_lid_crease);
x_L_upper_lid_ref = Array.copy(x_L_upper_lid);
y_L_upper_lid_ref = Array.copy(y_L_upper_lid);
x_L_lower_lid_ref = Array.copy(x_L_lower_lid);
y_L_lower_lid_ref = Array.copy(y_L_lower_lid);

x_R_upper_med_canth_ref = Array.copy(x_R_upper_med_canth);
y_R_upper_med_canth_ref = Array.copy(y_R_upper_med_canth);
x_R_upper_lid_med_to_lat_canth_ref = Array.copy(x_R_upper_lid_med_to_lat_canth);
y_R_upper_lid_med_to_lat_canth_ref = Array.copy(y_R_upper_lid_med_to_lat_canth);
x_R_lower_med_canth_ref = Array.copy(x_R_lower_med_canth);
y_R_lower_med_canth_ref = Array.copy(y_R_lower_med_canth);
x_R_lower_lid_med_to_lat_canth_ref = Array.copy(x_R_lower_lid_med_to_lat_canth);
y_R_lower_lid_med_to_lat_canth_ref = Array.copy(y_R_lower_lid_med_to_lat_canth);
x_L_upper_med_canth_ref = Array.copy(x_L_upper_med_canth);
y_L_upper_med_canth_ref = Array.copy(y_L_upper_med_canth);
x_L_upper_lid_med_to_lat_canth_ref = Array.copy(x_L_upper_lid_med_to_lat_canth);
y_L_upper_lid_med_to_lat_canth_ref = Array.copy(y_L_upper_lid_med_to_lat_canth);
x_L_lower_med_canth_ref = Array.copy(x_L_lower_med_canth);
y_L_lower_med_canth_ref = Array.copy(y_L_lower_med_canth);
x_L_lower_lid_med_to_lat_canth_ref = Array.copy(x_L_lower_lid_med_to_lat_canth);
y_L_lower_lid_med_to_lat_canth_ref = Array.copy(y_L_lower_lid_med_to_lat_canth);

x_L_eyebrow_top_overlap_right = Array.copy(x_L_eyebrow_top);
x_L_eyebrow_bot_overlap_right = Array.copy(x_L_eyebrow_bot);
x_L_lid_crease_overlap_right = Array.copy(x_L_lid_crease);
x_L_upper_lid_overlap_right = Array.copy(x_L_upper_lid);
x_L_lower_lid_overlap_right = Array.copy(x_L_lower_lid);

x_L_upper_med_canth_overlap_right = Array.copy(x_L_upper_med_canth);
x_L_upper_lid_med_to_lat_canth_overlap_right = Array.copy(x_L_upper_lid_med_to_lat_canth);
x_L_lower_med_canth_overlap_right = Array.copy(x_L_lower_med_canth);
x_L_lower_lid_med_to_lat_canth_overlap_right = Array.copy(x_L_lower_lid_med_to_lat_canth);


//Right side: subtract x_min value, y_
//min value = new origin at 0,0
//Left side,x: x_max - x_at point y: subtract y_min = this flips the graph horizontally and sets origin to 0,0

for(i=0;i<x_R_eyebrow_top.length;i++){
		x_R_eyebrow_top_ref[i] = -x_R_eyebrow_top[i]+x_R_eyebrow_topmax; 
		y_R_eyebrow_top_ref[i] = -y_R_eyebrow_top[i]+y_R_eyebrow_topmax;}
for(i=0;i<x_R_eyebrow_bot.length;i++){
		x_R_eyebrow_bot_ref[i] = -x_R_eyebrow_bot[i]+x_R_eyebrow_botmax; 
		y_R_eyebrow_bot_ref[i] = -y_R_eyebrow_bot[i]+y_R_eyebrow_botmax;}
if(yes_R_lid_crease==1){
for(i=0;i<x_R_lid_crease.length;i++){
		x_R_lid_crease_ref[i] = -x_R_lid_crease[i]+x_R_lid_creasemax; 
		y_R_lid_crease_ref[i] = -y_R_lid_crease[i]+y_R_lid_creasemax;}
}
for(i=0;i<x_R_upper_lid.length;i++){
		x_R_upper_lid_ref[i] = x_R_upper_lid[i]-x_R_upper_lidmin; 
		y_R_upper_lid_ref[i] = -y_R_upper_lid[i]+y_R_upper_lidmax;}
for(i=0;i<x_R_lower_lid.length;i++){
		x_R_lower_lid_ref[i] = x_R_lower_lid[i]-x_R_lower_lidmin; 
		y_R_lower_lid_ref[i] = y_R_lower_lid[i]-y_R_lower_lidmin;}

for(i=0;i<x_R_upper_med_canth.length;i++){
		x_R_upper_med_canth_ref[i] = x_R_upper_med_canth[i]-x_R_upper_med_canthmin; 
		y_R_upper_med_canth_ref[i] = -y_R_upper_med_canth[i]+y_R_upper_med_canthmax;}
for(i=0;i<x_R_lower_med_canth.length;i++){
		x_R_lower_med_canth_ref[i] = x_R_lower_med_canth[i]-x_R_lower_med_canthmin; 
		y_R_lower_med_canth_ref[i] = y_R_lower_med_canth[i]-y_R_lower_med_canthmin;}

for(i=0;i<x_R_upper_lid_med_to_lat_canth.length;i++){
		x_R_upper_lid_med_to_lat_canth_ref[i] = x_R_upper_lid_med_to_lat_canth[i]-x_R_upper_lid_med_to_lat_canthmin; 
		y_R_upper_lid_med_to_lat_canth_ref[i] = -y_R_upper_lid_med_to_lat_canth[i]+y_R_upper_lid_med_to_lat_canthmax;}
for(i=0;i<x_R_lower_lid_med_to_lat_canth.length;i++){
		x_R_lower_lid_med_to_lat_canth_ref[i] = x_R_lower_lid_med_to_lat_canth[i]-x_R_lower_lid_med_to_lat_canthmin; 
		y_R_lower_lid_med_to_lat_canth_ref[i] = y_R_lower_lid_med_to_lat_canth[i]-y_R_lower_lid_med_to_lat_canthmin;}


//The left sided x-values are multiplied by -1 to horizontally flip values before
//performing the translation to the standardized point x=0,y=0


x_shift_overlap_right = x_R_eyebrow_topmin+x_L_eyebrow_topmax;
for(i=0;i<x_L_eyebrow_top.length;i++){
		x_L_eyebrow_top_ref[i] = x_L_eyebrow_top[i]-x_L_eyebrow_topmin; 
		x_L_eyebrow_top_overlap_right[i] = x_L_eyebrow_top[i]*(-1)+x_shift_overlap_right; 
		y_L_eyebrow_top_ref[i] = -y_L_eyebrow_top[i]+y_L_eyebrow_topmax;}
x_shift_overlap_right = x_R_eyebrow_topmin+x_L_eyebrow_topmax;
for(i=0;i<x_L_eyebrow_bot.length;i++){
		x_L_eyebrow_bot_ref[i] = x_L_eyebrow_bot[i]-x_L_eyebrow_botmin; 
		x_L_eyebrow_bot_overlap_right[i] = x_L_eyebrow_bot[i]*(-1)+x_shift_overlap_right; 
		y_L_eyebrow_bot_ref[i] = -y_L_eyebrow_bot[i]+y_L_eyebrow_botmax;}
x_shift_overlap_right = x_R_lid_creasemin+x_L_lid_creasemax;

if(yes_L_lid_crease==1){
for(i=0;i<x_L_lid_crease.length;i++){
		x_L_lid_crease_ref[i] = x_L_lid_crease[i]-x_L_lid_creasemin; 
		x_L_lid_crease_overlap_right[i] = x_L_lid_crease[i]*(-1)+x_shift_overlap_right; 
		y_L_lid_crease_ref[i] = -y_L_lid_crease[i]+y_L_lid_creasemax;}}
x_shift_overlap_right = x_R_upper_lidmin+x_L_upper_lidmax;
for(i=0;i<x_L_upper_lid.length;i++){
		x_L_upper_lid_ref[i] = x_L_upper_lid[i]*(-1)+x_L_upper_lidmax; 
		x_L_upper_lid_overlap_right[i] = x_L_upper_lid[i]*(-1)+x_shift_overlap_right; 
		y_L_upper_lid_ref[i] = -y_L_upper_lid[i]+y_L_upper_lidmax;}
x_shift_overlap_right = x_R_lower_lidmin+x_L_lower_lidmax;
for(i=0;i<x_L_lower_lid.length;i++){
		x_L_lower_lid_ref[i] = x_L_lower_lid[i]*(-1)+x_L_lower_lidmax; 
		x_L_lower_lid_overlap_right[i] = x_L_lower_lid[i]*(-1)+x_shift_overlap_right; 
		y_L_lower_lid_ref[i] = y_L_lower_lid[i]-y_L_lower_lidmin;}
		
		x_shift_overlap_right = x_R_upper_med_canthmin+x_L_upper_med_canthmax;
for(i=0;i<x_L_upper_med_canth.length;i++){
		x_L_upper_med_canth_ref[i] = x_L_upper_med_canth[i]*(-1)+x_L_upper_med_canthmax; 
		x_L_upper_med_canth_overlap_right[i] = x_L_upper_med_canth[i]*(-1)+x_shift_overlap_right; 
		y_L_upper_med_canth_ref[i] = -y_L_upper_med_canth[i]+y_L_upper_med_canthmax;}
x_shift_overlap_right = x_R_lower_med_canthmin+x_L_lower_med_canthmax;
for(i=0;i<x_L_lower_med_canth.length;i++){
		x_L_lower_med_canth_ref[i] = x_L_lower_med_canth[i]*(-1)+x_L_lower_med_canthmax; 
		x_L_lower_med_canth_overlap_right[i] = x_L_lower_med_canth[i]*(-1)+x_shift_overlap_right; 
		y_L_lower_med_canth_ref[i] = y_L_lower_med_canth[i]-y_L_lower_med_canthmin;}
		
		x_shift_overlap_right = x_R_upper_lid_med_to_lat_canthmin+x_L_upper_lid_med_to_lat_canthmax;
for(i=0;i<x_L_upper_lid_med_to_lat_canth.length;i++){
		x_L_upper_lid_med_to_lat_canth_ref[i] = x_L_upper_lid_med_to_lat_canth[i]*(-1)+x_L_upper_lid_med_to_lat_canthmax; 
		x_L_upper_lid_med_to_lat_canth_overlap_right[i] = x_L_upper_lid_med_to_lat_canth[i]*(-1)+x_shift_overlap_right; 
		y_L_upper_lid_med_to_lat_canth_ref[i] = -y_L_upper_lid_med_to_lat_canth[i]+y_L_upper_lid_med_to_lat_canthmax;}
x_shift_overlap_right = x_R_lower_lid_med_to_lat_canthmin+x_L_lower_lid_med_to_lat_canthmax;
for(i=0;i<x_L_lower_lid_med_to_lat_canth.length;i++){
		x_L_lower_lid_med_to_lat_canth_ref[i] = x_L_lower_lid_med_to_lat_canth[i]*(-1)+x_L_lower_lid_med_to_lat_canthmax; 
		x_L_lower_lid_med_to_lat_canth_overlap_right[i] = x_L_lower_lid_med_to_lat_canth[i]*(-1)+x_shift_overlap_right; 
		y_L_lower_lid_med_to_lat_canth_ref[i] = y_L_lower_lid_med_to_lat_canth[i]-y_L_lower_lid_med_to_lat_canthmin;}
		
		
Array.show("XY Coordinates Scaled",parentfoldername,foldername,imagename,landmarks_label,x_landmarks,y_landmarks,
_,x_R_eyebrow_top, y_R_eyebrow_top, x_R_eyebrow_bot, y_R_eyebrow_bot,x_R_lid_crease, y_R_lid_crease,
x_R_upper_med_canth,y_R_upper_med_canth,
x_R_upper_lid,y_R_upper_lid,
x_R_upper_lid_med_to_lat_canth,y_R_upper_lid_med_to_lat_canth,
x_R_lower_med_canth,y_R_lower_med_canth,
x_R_lower_lid,y_R_lower_lid,
x_R_lower_lid_med_to_lat_canth,y_R_lower_lid_med_to_lat_canth,
x_L_eyebrow_top_overlap_right, y_L_eyebrow_top, x_L_eyebrow_bot_overlap_right, y_L_eyebrow_bot, x_L_lid_crease_overlap_right, y_L_lid_crease, 
x_L_upper_med_canth_overlap_right,y_L_upper_med_canth,
x_L_upper_lid_overlap_right,y_L_upper_lid,
x_L_upper_lid_med_to_lat_canth_overlap_right,y_L_upper_lid_med_to_lat_canth,
x_L_lower_med_canth_overlap_right,y_L_lower_med_canth,
x_L_lower_lid_overlap_right,y_L_lower_lid,
x_L_lower_lid_med_to_lat_canth_overlap_right,y_L_lower_lid_med_to_lat_canth,
__,x_R_eyebrow_top_ref, y_R_eyebrow_top_ref, x_R_eyebrow_bot_ref, y_R_eyebrow_bot_ref,x_R_lid_crease_ref, y_R_lid_crease_ref, 
x_R_upper_med_canth_ref,y_R_upper_med_canth_ref,
x_R_upper_lid_ref,y_R_upper_lid_ref,
x_R_upper_lid_med_to_lat_canth_ref,y_R_upper_lid_med_to_lat_canth_ref,
x_R_lower_med_canth_ref,y_R_lower_med_canth_ref,
x_R_lower_lid_ref,y_R_lower_lid_ref,
x_R_lower_lid_med_to_lat_canth_ref,y_R_lower_lid_med_to_lat_canth_ref,
x_L_eyebrow_top_ref, y_L_eyebrow_top_ref, x_L_eyebrow_bot_ref, y_L_eyebrow_bot_ref, 
x_L_lid_crease_ref, y_L_lid_crease_ref, 
x_L_upper_med_canth_ref,y_L_upper_med_canth_ref,
x_L_upper_lid_ref,y_L_upper_lid_ref,
x_L_upper_lid_med_to_lat_canth_ref,y_L_upper_lid_med_to_lat_canth_ref,
x_L_lower_med_canth_ref,y_L_lower_med_canth_ref,
x_L_lower_lid_ref,y_L_lower_lid_ref,
x_L_lower_lid_med_to_lat_canth_ref,y_L_lower_lid_med_to_lat_canth_ref);


//curve_label = newArray("R_eyebrow_top","R_eyebrow_bot","R_lid_crease","R_upper_lid","R_lower_lid","L_eyebrow_top","L_eyebrow_bot","L_lid_crease","L_upper_lid","L_lower_lid",
//"R_eyebrow_top_ref","R_eyebrow_bot_ref","R_lid_crease_ref","R_upper_lid_ref","R_lower_lid_ref","L_eyebrow_top_ref","L_eyebrow_bot_ref","L_lid_crease_ref","L_upper_lid_ref",
 //"L_lower_lid");
 
 curve_label = newArray("R_eyebrow_top",
"R_eyebrow_bot",
"R_lid_crease",
 	"R_upper_lid",
 	"R_upper_lid_med_to_lat_canth",
 	"R_lower_lid",
 	"R_lower_lid_med_to_lat_canth",
 	"L_eyebrow_top",
 	"L_eyebrow_bot",
 	"L_lid_crease",
 	"L_upper_lid",
 	"L_upper_lid_med_to_lat_canth",
 	"L_lower_lid",
 	"L_lower_lid_med_to_lat_canth",
"R_eyebrow_top_ref",
"R_eyebrow_bot_ref",
"R_lid_crease_ref",
 	"R_upper_lid_ref",
 	"R_upper_lid_med_to_lat_canth_ref",
 	"R_lower_lid_ref",
 	"R_lower_lid_med_to_lat_canth_ref",
 	"L_eyebrow_top_ref",
 	"L_eyebrow_bot_ref",
 	"L_lid_crease_ref",
 	"L_upper_lid_ref",
 	"L_upper_lid_med_to_lat_canth_ref",
 	"L_lower_lid_ref", 	 	
 	"L_lower_lid_med_to_lat_canth_ref");

a = newArray(28);
b = newArray(28);
c = newArray(28);
d = newArray(28);
e = newArray(28);
r_squared = newArray(28);
i=0;
 Fit.doFit("4th Degree Polynomial", x_R_eyebrow_top, y_R_eyebrow_top);
    //    Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
 Fit.doFit("4th Degree Polynomial", x_R_eyebrow_bot, y_R_eyebrow_bot);
    //    Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
if(yes_R_lid_crease == 1){
	 Fit.doFit("4th Degree Polynomial", x_R_lid_crease, y_R_lid_crease);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;}
	else{ //changes curve coefficients to 0 in the case that user selects "no lid crease" 
	a[i] = 0;
	b[i] = 0;
	c[i] = 0;
	d[i] = 0;
	e[i] = 0;
	r_squared[i] = 0;
	}
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_R_upper_lid, y_R_upper_lid);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
		 Fit.doFit("4th Degree Polynomial", x_R_upper_lid_med_to_lat_canth,y_R_upper_lid_med_to_lat_canth);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_R_lower_lid, y_R_lower_lid);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
Fit.doFit("4th Degree Polynomial", x_R_lower_lid_med_to_lat_canth,y_R_lower_lid_med_to_lat_canth);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
 Fit.doFit("4th Degree Polynomial", x_L_eyebrow_top_overlap_right, y_L_eyebrow_top);
     //   Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
 Fit.doFit("4th Degree Polynomial", x_L_eyebrow_bot_overlap_right, y_L_eyebrow_bot);
     //   Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	if(yes_L_lid_crease == 1){
	 Fit.doFit("4th Degree Polynomial", x_L_lid_crease_overlap_right, y_L_lid_crease);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;}
		else{ //changes curve coefficients to 0 in the case that user selects "no lid crease" 
	a[i] = 0;
	b[i] = 0;
	c[i] = 0;
	d[i] = 0;
	e[i] = 0;
	r_squared[i] = 0;
	}

i=i+1;

	 Fit.doFit("4th Degree Polynomial", x_L_upper_lid_overlap_right, y_L_upper_lid);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_L_upper_lid_med_to_lat_canth_overlap_right,y_L_upper_lid_med_to_lat_canth);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_L_lower_lid_overlap_right, y_L_lower_lid);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_L_lower_lid_med_to_lat_canth_overlap_right,y_L_lower_lid_med_to_lat_canth);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
 Fit.doFit("4th Degree Polynomial", x_R_eyebrow_top_ref, y_R_eyebrow_top_ref);
    //    Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
 Fit.doFit("4th Degree Polynomial", x_R_eyebrow_bot_ref, y_R_eyebrow_bot_ref);
    //    Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	if(yes_R_lid_crease == 1){
	 Fit.doFit("4th Degree Polynomial", x_R_lid_crease_ref, y_R_lid_crease_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
}
		else{ //changes curve coefficients to 0 in the case that user selects "no lid crease" 
	a[i] = 0;
	b[i] = 0;
	c[i] = 0;
	d[i] = 0;
	e[i] = 0;
	r_squared[i] = 0;
	}
	
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_R_upper_lid_ref, y_R_upper_lid_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_R_upper_lid_med_to_lat_canth_ref,y_R_upper_lid_med_to_lat_canth_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_R_upper_lid_ref, y_R_upper_lid_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_R_lower_lid_med_to_lat_canth_ref,y_R_lower_lid_med_to_lat_canth_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
 Fit.doFit("4th Degree Polynomial", x_L_eyebrow_top_ref, y_L_eyebrow_top_ref);
     //   Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
 Fit.doFit("4th Degree Polynomial", x_L_eyebrow_bot_ref, y_L_eyebrow_bot_ref);
     //   Fit.plot();
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
if(yes_L_lid_crease == 1){
	 Fit.doFit("4th Degree Polynomial", x_L_lid_crease_ref, y_L_lid_crease_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;}
	else{
	a[i] = 0;
	b[i] = 0;
	c[i] = 0;
	d[i] = 0;
	e[i] = 0;
	r_squared[i] = 0;
	}
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_L_upper_lid_ref, y_L_upper_lid_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_L_upper_lid_med_to_lat_canth_ref,y_L_upper_lid_med_to_lat_canth_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_L_lower_lid_ref, y_L_lower_lid_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
	i=i+1;
	 Fit.doFit("4th Degree Polynomial", x_L_lower_lid_med_to_lat_canth_ref,y_L_lower_lid_med_to_lat_canth_ref);
	a[i] = Fit.p(0);
	b[i] = Fit.p(1);
	c[i] = Fit.p(2);
	d[i] = Fit.p(3);
	e[i] = Fit.p(4);
	r_squared[i] = Fit.rSquared;
i=i+1;
num_fit_curves = i;
	
	Array.show("4th deg polynomial fit lines",parentfoldername,foldername,imagename,curve_label,a,b,c,d,e,r_squared);


curve_coeffs = newArray("",a[0],b[0],c[0],d[0],e[0],r_squared[0],"",a[1],b[1],c[1],d[1],e[1],r_squared[1],"",a[2],b[2],c[2],d[2],e[2],r_squared[2],
"",a[3],b[3],c[3],d[3],e[3],r_squared[3],"",a[4],b[4],c[4],d[4],e[4],r_squared[4],"",a[5],b[5],c[5],d[5],e[5],r_squared[5],
"",a[6],b[6],c[6],d[6],e[6],r_squared[6],"",a[7],b[7],c[7],d[7],e[7],r_squared[7],"",a[8],b[8],c[8],d[8],e[8],r_squared[8],
"",a[9],b[9],c[9],d[9],e[9],r_squared[9],
"",a[10],b[10],c[10],d[10],e[10],r_squared[10],"",a[11],b[11],c[11],d[11],e[11],r_squared[11],"",a[12],b[12],c[12],d[12],e[12],r_squared[12],
"",a[13],b[13],c[13],d[13],e[13],r_squared[13],"",a[14],b[14],c[14],d[14],e[14],r_squared[14],"",a[15],b[15],c[15],d[15],e[15],r_squared[15],
"",a[16],b[16],c[16],d[16],e[16],r_squared[16],"",a[17],b[17],c[17],d[17],e[17],r_squared[17],"",a[18],b[18],c[18],d[18],e[18],r_squared[18],
"",a[19],b[19],c[19],d[19],e[19],r_squared[19],"",a[20],b[20],c[20],d[20],e[20],r_squared[20],"",a[21],b[21],c[21],d[21],e[21],r_squared[21],
"",a[22],b[22],c[22],d[22],e[22],r_squared[22],"",a[23],b[23],c[23],d[23],e[23],r_squared[23],"",a[24],b[24],c[24],d[24],e[24],r_squared[24],
"",a[25],b[25],c[25],d[25],e[25],r_squared[25],"",a[26],b[26],c[26],d[26],e[26],r_squared[26],"",a[27],b[27],c[27],d[27],e[27],r_squared[27]);



curve_labels = 0;
for (j=0; j<curve_label.length;j++){
	a = newArray("a"+j+1);
	b = newArray("b"+j+1);
	c = newArray("c"+j+1);
	d = newArray("d"+j+1);
	e = newArray("e"+j+1);
	r_squared = newArray("r_squared"+j+1);
curve_labels = Array.concat(curve_labels,curve_label[j],a,b,c,d,e,r_squared);
}
  curve_labels = Array.slice(curve_labels,1); //removes first element from array which was the 0
//Array.print(curve_labels);

periorbit_measures = Array.concat(periorbit_measures, curve_coeffs);
periorbit_measures_labels = Array.concat(periorbit_measures_labels, curve_labels);

for (i=0; i<periorbit_measures_labels.length;i++){
	setResult(periorbit_measures_labels[i], 0, periorbit_measures[i]);
}
updateResults();


//Save everything

//Checks if fit was good. If not, offers a chance for a redo:
r_squared_ref = Array.copy(r_squared);

save_data = 1; //defaults to saving your data

//Corrects for if there are R-squared values = 0 because the lid crease
//was not measured. It turns that 0 into 1000 (will make it more obvious
//that it's not a real value
for (i=0; i<r_squared_ref.length;i++){
if(r_squared_ref[i]==0){
	r_squared_ref[i] = 1000;
	}
}

Array.getStatistics(r_squared_ref, r_squared_refmin, r_squared_refmax,r_squared_refmean,r_squared_refstd);
	yes_no = 0;
	if (r_squared_refmin<0.88){
		print("Worst R-value of "+r_squared_refmin+"! Consider repeating measurements!");
	yes_no = 0;
	yes_no = getBoolean("Poor fit (R-squared < 0.88) for at least one best-fit curve\n"
	+"Some points are probably not in a good position.\n"
	+"Or this could be a glitch.\n"
	+" \n"
	+"Would you still like to save your results?");
	if(yes_no==1){
	save_data = 1;}
	if(yes_no==0){
	save_data = 0;} //this tells the script not to save your data
	}

if(save_data == 1){
print(path_new_folder); 
File.makeDirectory(path_new_folder); 
//li*st = getFileList(dir); 

 
run("From ROI Manager");
save(path_new_folder+File.separator+imageName+"processed.tif");
print("Saved image: "+path_new_folder+File.separator+imageName+"_processed.tif");
selectWindow("Results");
saveAs("Results",path_new_folder+File.separator+imageName+"_periobit_measures.csv");
selectWindow("4th deg polynomial fit lines");
saveAs("Results",path_new_folder+File.separator+imageName+"_fitlines.csv");
//  run("Close");
selectWindow("XY Coordinates");
saveAs("Results",path_new_folder+File.separator+imageName+"_xy_coordinates_pixels.csv");
//  run("Close");
  selectWindow("XY Coordinates Scaled");
saveAs("Results",path_new_folder+File.separator+imageName+"_xy_coordinates_mm.csv");
//  run("Close");
//IJ.renameResults(name);
roiManager("Deselect");
roiManager("Save",path_new_folder+File.separator+imageName+"RoiSet.zip");

roiManager("Show All"); //shows all the points that were made and calculated
selectWindow("Results");

run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column save_row");
String.copyResults();
}	



//This function calculates the Y-value of a given point in between
//two other points as defined on a line between those two points,
//given an x-value of x_input using x_point, y_points as the
//set of reference points
function calc_Y(x_input,x_points,y_points){
diff_value = newArray(x_points.length);
for (i = 0;i<x_points.length; i++) {
	diff_value[i] = abs(x_input-x_points[i]);}
rankPosDiff = Array.rankPositions(diff_value); //outputs array of indices
//of lowest to highest values of the diff_value array.
rankPos_x_points = Array.rankPositions(x_points); //same but for x_points array
Array.getStatistics(x_points, x_pointsmin, x_pointsmax,x_pointsmean,x_pointsstd);
p1 = rankPosDiff[0];
p2 = rankPosDiff[1];
y_output = (x_input-x_points[p1])*(y_points[p2]-y_points[p1])/(x_points[p2]-x_points[p1])+y_points[p1]; 
if (x_input<x_pointsmin) {
//in case input x point is to the left of the leftmost eyebrow/eyelid point
//y_output becomes the y value at the smallest x value of the eyebrow/eyelid
y_output = y_points[rankPos_x_points[0]];}
if (x_input>x_pointsmax) {
//in case input x point is to the right of the rightmost eyebrow/eyelid point
//y_output becomes the y value at the largest x value of the eyebrow/eyelid
y_output = y_points[rankPos_x_points[rankPos_x_points.length-1]];}
return y_output;
}

//This function draws a 4th degree polynomial best fitline on the image using
//a set of reference points 
function fitline_4th_deg(x_points,y_points){
		 Fit.doFit("4th Degree Polynomial",x_points,y_points);
	   a_c = Fit.p(0);
	b_c = Fit.p(1);
	c_c = Fit.p(2);
	d_c = Fit.p(3);
	e_c = Fit.p(4);
	
Array.getStatistics(x_points, x_pointsmin, x_pointsmax,x_pointsmean,x_pointsstd);
min_max = newArray(x_pointsmin, x_pointsmax);
x_input= Array.resample(min_max,100);
yfit = newArray(100);
x_y_output = newArray(200);
for ( i=0 ; i < x_input.length; i++) {
		b_calc_c= b_c*x_input[i];
		c_calc_c= c_c*x_input[i]*x_input[i];
		d_calc_c= d_c*x_input[i]*x_input[i]*x_input[i];
		e_calc_c= e_c*x_input[i]*x_input[i]*x_input[i]*x_input[i];
		yfit[i] = a_c+b_calc_c+c_calc_c+d_calc_c+e_calc_c;
x_y_output[i*2] = x_input[i];
x_y_output[i*2+1] = yfit[i];
}
Array.print(x_input);
Array.print(yfit);
Array.print(x_y_output);
print(x_y_output.length+" elements in x_y_output");
//Note that for whatever reason ImageJ doesn't like array inputs so I had to generate this list of points for it not to hate me
//This was generated using a custom tool I made called multi_line_label_maker, which can make these for an arbitrary number of points
makeLine(x_input[0], yfit[0], x_input[1], yfit[1], x_input[2], yfit[2], x_input[3], yfit[3], x_input[4], yfit[4], x_input[5], yfit[5], x_input[6], 
yfit[6], x_input[7], yfit[7], x_input[8], yfit[8], x_input[9], yfit[9], x_input[10], yfit[10], x_input[11], yfit[11], x_input[12], yfit[12], 
x_input[13], yfit[13], x_input[14], yfit[14], x_input[15], yfit[15], x_input[16], yfit[16], x_input[17], yfit[17], x_input[18], yfit[18], 
x_input[19], yfit[19], x_input[20], yfit[20], x_input[21], yfit[21], x_input[22], yfit[22], x_input[23], yfit[23], x_input[24], yfit[24], 
x_input[25], yfit[25], x_input[26], yfit[26], x_input[27], yfit[27], x_input[28], yfit[28], x_input[29], yfit[29], x_input[30], yfit[30], 
x_input[31], yfit[31], x_input[32], yfit[32], x_input[33], yfit[33], x_input[34], yfit[34], x_input[35], yfit[35], x_input[36], yfit[36], 
x_input[37], yfit[37], x_input[38], yfit[38], x_input[39], yfit[39], x_input[40], yfit[40], x_input[41], yfit[41], x_input[42], yfit[42], 
x_input[43], yfit[43], x_input[44], yfit[44], x_input[45], yfit[45], x_input[46], yfit[46], x_input[47], yfit[47], x_input[48], yfit[48], 
x_input[49], yfit[49], x_input[50], yfit[50], x_input[51], yfit[51], x_input[52], yfit[52], x_input[53], yfit[53], x_input[54], yfit[54], 
x_input[55], yfit[55], x_input[56], yfit[56], x_input[57], yfit[57], x_input[58], yfit[58], x_input[59], yfit[59], x_input[60], yfit[60], 
x_input[61], yfit[61], x_input[62], yfit[62], x_input[63], yfit[63], x_input[64], yfit[64], x_input[65], yfit[65], x_input[66], yfit[66], 
x_input[67], yfit[67], x_input[68], yfit[68], x_input[69], yfit[69], x_input[70], yfit[70], x_input[71], yfit[71], x_input[72], yfit[72], 
x_input[73], yfit[73], x_input[74], yfit[74], x_input[75], yfit[75], x_input[76], yfit[76], x_input[77], yfit[77], x_input[78], yfit[78], 
x_input[79], yfit[79], x_input[80], yfit[80], x_input[81], yfit[81], x_input[82], yfit[82], x_input[83], yfit[83], x_input[84], yfit[84], 
x_input[85], yfit[85], x_input[86], yfit[86], x_input[87], yfit[87], x_input[88], yfit[88], x_input[89], yfit[89], x_input[90], yfit[90], 
x_input[91], yfit[91], x_input[92], yfit[92], x_input[93], yfit[93], x_input[94], yfit[94], x_input[95], yfit[95], x_input[96], yfit[96], 
x_input[97], yfit[97], x_input[98], yfit[98], x_input[99], yfit[99]);
}

function fit_error_check(x_points,y_points){
		 Fit.doFit("4th Degree Polynomial",x_points,y_points);
	   a_c = Fit.p(0);
	b_c = Fit.p(1);
	c_c = Fit.p(2);
	d_c = Fit.p(3);
	e_c = Fit.p(4);
	r_squared_c = Fit.rSquared;
output_answer = 1; //this tells the code to continue foward by default if r_squared is above .88
	if (r_squared_c<0.88){
		print("R-value of "+r_squared_c+"! Consider repeating measurements!");
	yes_no = 0;
	yes_no = getBoolean("Poor fit (R-squared = "+r_squared_c+") for best-fit curve.\n"
	+"Some points are probably not in good position.\n"
	+" \n"
	+"Would you like to go back and fix the selection?");
	if(yes_no==1){
	output_answer = 0;}
	if(yes_no==0){
	output_answer = 1;} //this tells the code to continue forward
	}
return output_answer;
}