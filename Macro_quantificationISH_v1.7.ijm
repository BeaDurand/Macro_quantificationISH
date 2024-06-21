//selecting directory to open the data 
//
run("Close All");
waitForUser("Please veryfy that the directory ONLY contains the images to be analyzed\nand\nopen one of them");
open();
close();
path=File.directory;

//Asking about requirement of median filter
//
Dialog.create("Median filter option");
	Dialog.addNumber("Radious of median filter", 2);
Dialog.show();
medi = Dialog.getNumber();

//reading ne number of files to be analyzed
list = getFileList(path);
nf=list.length;

//Prepaing output directories
//
res_path=path+"results_med_"+medi;
File.makeDirectory(res_path);

blue_path=res_path+"/blue_channel";
File.makeDirectory(blue_path);

bkg_path=res_path+"/bkg_corrected";
File.makeDirectory(bkg_path);

sm_path=res_path+"/signal_mask";
File.makeDirectory(sm_path);


for (i=0; i<nf; i++)
{
	//opening images and selecting blue channel
	//
		open(path+list[i]);
		run("Split Channels");
		close(list[i]+" (red)");
		close(list[i]+" (green)");
		run("Invert");
		saveAs("Tiff", blue_path+"/"+list[i]+"_blue.tif");
		close();
	//
	//substracting background
	//
		open(blue_path+"/"+list[i]+"_blue.tif");
			if(i%2==0){
		setAutoThreshold("Default dark");
		run("Set Measurements...", "mean redirect=None decimal=0");
		run("Analyze Particles...", "clear summarize");
		bkg=getResult("Mean");
		run("Subtract...", "value="+bkg);
			} else {
		setAutoThreshold("Default dark");
		run("Set Measurements...", "mean redirect=None decimal=0");
		run("Analyze Particles...", "clear summarize");
		run("Subtract...", "value="+bkg);
			}
		saveAs("Tiff", bkg_path+"/"+list[i]+"_blue-bkg.tif");
		close();
		
		//	Closing intermediate results corresponding to the background estimation
		//
			selectWindow("Summary"); 
			run("Close"); 
		//
	//
}

//computing signal parameters
//
for (i=0; i<nf; i++)
{
		open(bkg_path+"/"+list[i]+"_blue-bkg.tif");
		if(medi>0)
		{
			run("Median...", "radius="+medi);
		}
		run("Set Measurements...", "area mean integrated redirect=None decimal=2");
		setAutoThreshold("Default dark");
		run("Analyze Particles...", "clear summarize");
		run("Convert to Mask");
		run("Invert LUT");
		saveAs("Tiff", sm_path+"/"+list[i]+"_signal_msk.tif");
		close();
}

//saving results
//
//selectWindow("Results"); 
//run("Close"); 
selectWindow("Summary"); 
saveAs("Text", res_path+"/"+"Summary.txt");
selectWindow("Summary.txt"); 
run("Close"); 

//making result montage
for (i=0; i<nf; i++)
{
	open(path+list[i]);
}
run("Images to Stack", "method=[Copy (center)] name=a title=a.tif use");
run("Images to Stack", "method=[Copy (center)] name=b title=b.tif use");
run("Combine...", "stack1=a stack2=b");
close("a");
close("b");
rename("tmp");

for (i=0; i<(list.length-0); i++)
{
	open(blue_path+"/"+list[i]+"_blue.tif");
}
run("Images to Stack", "method=[Copy (center)] name=a title=a.tif use");
run("Images to Stack", "method=[Copy (center)] name=b title=b.tif use");
run("Combine...", "stack1=a stack2=b");
close("a");
close("b");
run("RGB Color");
run("Combine...", "stack1=tmp stack2=[Combined Stacks] combine");
rename("tmp");

for (i=0; i<(list.length-0); i++)
{
	open(bkg_path+"/"+list[i]+"_blue-bkg.tif");
}
run("Images to Stack", "method=[Copy (center)] name=a title=a.tif use");
run("Images to Stack", "method=[Copy (center)] name=b title=b.tif use");
run("Combine...", "stack1=a stack2=b");
close("a");
close("b");
run("RGB Color");
run("Combine...", "stack1=tmp stack2=[Combined Stacks] combine");
rename("tmp");

for (i=0; i<(list.length-0); i++)
{
	open(sm_path+"/"+list[i]+"_signal_msk.tif");
}
run("Images to Stack", "method=[Copy (center)] name=a title=a.tif use");
run("Images to Stack", "method=[Copy (center)] name=b title=b.tif use");
run("Combine...", "stack1=a stack2=b");
close("a");
close("b");
run("RGB Color");
run("Combine...", "stack1=tmp stack2=[Combined Stacks] combine");

run("Rotate 90 Degrees Left");
saveAs("Tiff", res_path+"/Summary.tif");






