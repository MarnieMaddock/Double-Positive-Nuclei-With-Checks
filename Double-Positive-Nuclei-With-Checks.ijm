// USAGE: Use in FIJI
//
// Author: Marnie L Maddock (University of Wollongong)
// mmaddock@uow.edu.au, mlm715@uowmail.edu.au
// 5.07.2024
/* Copyright 2024 Marnie Maddock

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * Instructions
 *  Use for .tif images
 *  Images that have no cells (all black for example, will have the error: No window with "Results" found. Remove this black image from the dataset.
	Press run
	
*/

// Fresh Start
roiManager("reset");
roiManager("Show None");

// Set up directories
dir1 = getDirectory("Choose Source Directory of images");
resultsDir = dir1+"CSV_results/"; // Specify file path to make new directory within dir1
resultsDir2 = dir1+"ROI_images/"; // Specify file path to make new directory within dir1
File.makeDirectory(resultsDir); // Create a directory within dir1 called CSV_results
File.makeDirectory(resultsDir2); // Create a directory within dir1 called ROI_images
list = getFileList(dir1);


// Prompt the user to specify channel names
Dialog.create("Specify Channel Names");
Dialog.addString("Name for Nuclei channel (e.g., DAPI):", "DAPI");
Dialog.addString("Name for channel that should localise with the nuclei (e.g., SOX10):", "SOX10");
Dialog.show();

// Get the user-specified channel names
C1_name = Dialog.getString();
C2_name = Dialog.getString();

// Prompt user to specify channel order
Dialog.create("Specify Channel Numbers");
Dialog.addNumber("Channel number for " + C1_name, 1);
Dialog.addNumber("Channel number for " + C2_name, 2);
Dialog.addCheckbox("Transmitted light channel present?", true);
Dialog.addNumber("Channel number for transmitted light", 3);
Dialog.addCheckbox("Keep transmitted light channel open?", false);
Dialog.show();

// Get the channel numbers
C1_num = Dialog.getNumber();
C2_num = Dialog.getNumber();
hasTrans = Dialog.getCheckbox();
TL_num = Dialog.getNumber();
keep_transmitted = Dialog.getCheckbox();

// Preprocessing settings
Dialog.create("Select Pre-processing Options");
Dialog.addCheckbox("Median Filter", true);
Dialog.addNumber("Median Filter Radius. Ignore option if N/A", 3);
Dialog.addCheckbox("Unsharp Mask", false);
Dialog.addNumber("Unsharp Mask Radius. Ignore option if N/A", 1);
Dialog.addNumber("Unsharp Mask Weight. Ignore option if N/A", 0.6);
Dialog.addCheckbox("Watershed", true);
Dialog.show();

// Save options
median_filter = Dialog.getCheckbox();
median_filter_radius = Dialog.getNumber();
unsharp_mask = Dialog.getCheckbox();
unsharp_radius = Dialog.getNumber();
unsharp_weight = Dialog.getNumber();
watershed = Dialog.getCheckbox();

// Threshold settings
Dialog.create("Adaptive Threshold Settings");
Dialog.addNumber("Block size", 341);
Dialog.addNumber("Then Subtract", -49);
Dialog.show();

// Save options
block_num = Dialog.getNumber();
subtract_num = Dialog.getNumber();

// Analyze Particles Options
Dialog.create("Analyze Particles Settings");
Dialog.addNumber("Minimum Particle Size:", 0);
Dialog.addNumber("Minimum Circularity:", 0.00);
Dialog.addNumber("Maximum Circularity:", 1.00);
Dialog.show();

// Retrieve the values
min_size = Dialog.getNumber();
min_circularity = Dialog.getNumber();
max_circularity = Dialog.getNumber();

// Build the options string using the numbers supplied
ap_options = "size=" + min_size + "-Infinity circularity=" + min_circularity + "-" + max_circularity + " show=Overlay display exclude clear summarize overlay add";


//--------Save options selected to a txt file---------
// Example snippet for building the options text in ImageJ macro language

optionsText = "Channel Names:\n";
optionsText += "  Nuclei channel: " + C1_name + "\n";
optionsText += "  Localising channel: " + C2_name + "\n\n";

optionsText += "Channel Numbers:\n";
optionsText += "  " + C1_name + " channel: " + C1_num + "\n";
optionsText += "  " + C2_name + " channel: " + C2_num + "\n";

if (hasTrans) {
    optionsText += "  Transmitted light channel: Yes, channel " + TL_num + "\n";
} else {
    optionsText += "  Transmitted light channel: No\n";
}

// Use if/else for keep_transmitted
if (keep_transmitted) {
    optionsText += "  Keep transmitted light open: Yes\n\n";
} else {
    optionsText += "  Keep transmitted light open: No\n\n";
}

optionsText += "Pre-processing Options:\n";
if (median_filter) {
    optionsText += "  Median Filter: Yes, radius " + median_filter_radius + "\n";
} else {
    optionsText += "  Median Filter: No\n";
}

if (unsharp_mask) {
    optionsText += "  Unsharp Mask: Yes, radius " + unsharp_radius + ", weight " + unsharp_weight + "\n";
} else {
    optionsText += "  Unsharp Mask: No\n";
}

if (watershed) {
    optionsText += "  Watershed: Yes\n\n";
} else {
    optionsText += "  Watershed: No\n\n";
}

optionsText += "Threshold Settings:\n";
optionsText += "  Block size: " + block_num + "\n";
optionsText += "  Then Subtract: " + subtract_num + "\n\n";

optionsText += "Analyze Particles Settings:\n";
optionsText += "  Minimum Particle Size: " + min_size + "\n";
optionsText += "  Circularity: " + min_circularity + " - " + max_circularity + "\n\n";

// Append file save information and current date
optionsText += "\nCSV files saved to: " + resultsDir + "\n";
optionsText += "ROI images saved to: " + resultsDir2 + "\n";


// Save the options to a text file in your results directory
File.saveString(optionsText, resultsDir + "Analysis_Options.txt");

// Start Batch Processing of .tif files
processFolder(dir1);
function processFolder(dir1) {
    list = getFileList(dir1);
    list = Array.sort(list);
    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], ".tif")) {
            processFile(dir1, resultsDir, list[i]);
        }
    }
} 

function processFile(dir1, resultsDir, file){

	open(dir1 + File.separator + file); // Open file within dir1

			title = getTitle(); //Save name of image to title
			run("Set Measurements...", "limit display add redirect=None decimal=8"); // Set what measurements are required for analyze particles i.e. counts only
			
			Stack.getDimensions(width, height, channels, slices, frames); // Get the dimensions of the image
			
			// Check if the image has multiple Z slices
			if (slices > 1) {
			    // If there are multiple slices, create a max projection
			    run("Z Project...", "projection=[Max Intensity]");
			    rename(title); // Rename the max projection to not include "MAX_"
			} 
			
			// Split the channels
			run("Split Channels");
			
			// Loop through channels 1 to 5
			for (i = 1; i <= 5; i++) {
			    keep = false;
			    // Check if this channel is one of the ones the user wants to keep
			    if (i == C1_num) {
			        keep = true;
			    }
			    if (i == C2_num) {
			        keep = true;
			    }
			    if (hasTrans && keep_transmitted && i == TL_num) {
			        keep = true;
			    }
			    // If this channel is not selected, close it if open
			    if (!keep) {
			        winName = "C" + i + "-" + title;
			        if (isOpen(winName)) {
			            close(winName);
			        }
			    }
			}
			
			// --- Duplicate selected channels for reference ---			
			// For channel C1:
			selectWindow("C" + C1_num + "-" + title);
			run("Duplicate...", " ");  // duplicate the current image
			rename(getTitle() + "_duplicate");  // rename the newly duplicated image
			C1_dupe_title = getTitle();
			
			// For channel C2:
			selectWindow("C" + C2_num + "-" + title);
			run("Duplicate...", " ");
			rename(getTitle() + "_duplicate");
			C2_dupe_title = getTitle();
			
			// Create coloc image
			if (isOpen(C1_dupe_title) && isOpen(C2_dupe_title)) {
			// Merge the two channels into a composite image
    		run("Merge Channels...", "c1=[" + C1_dupe_title + "] c2=[" + C2_dupe_title + "] create keep");
    		rename(getTitle() + "_coloc");
    		coloc_dupe_title = getTitle();
			}
			
			// Create an array of channels you want to pre-process (for example, C1 and C2)
			channelsToProcess = newArray(C1_num, C2_num);

			// --- Pre-process the selected channels ---	
			for (i = 0; i < channelsToProcess.length; i++) {
			    channel = channelsToProcess[i];
			    // Select the current channel's window, e.g., "C1-<title>" or "C2-<title>"
			    selectWindow("C" + channel + "-" + title);
			    
				// Pre-processing of image
				if (median_filter) {
	    			run("Median...", "radius=" + median_filter_radius);
				}
				
				if (unsharp_mask) {
					run("Unsharp Mask...", "radius=" + unsharp_radius + " mask=" + unsharp_weight);
				}
	
				run("adaptiveThr ", "using=Mean from=" + block_num + " then=" + subtract_num); // Threshold image using adaptive thresholding. The numbers specified can be optimised for your own image by going to Plugins --> Adaptive Thresholding
				if (watershed) {
	    			run("Watershed");
				} // Watershed segments cells close together
			}
			wait(2000);
			
			// ===== Nuclei Positive Cell Analysis =====
			// Select the nuclei channel
			selectWindow("C" + C1_num + "-" + title);
			run("Analyze Particles...", ap_options);
			
			
			selectWindow(C1_dupe_title);
			// Show all ROIs so you can review or edit them.
			roiManager("Show All");
		    waitForUser("Check ROIs", "Review or edit these ROIs in the ROI Manager. You can add, delete, or merge them. When satisfied, click OK.");
		    
// Refresh the overlay:
			// Clear any current overlay from the active image.
			run("Remove Overlay");
			
			
			// Re-add the ROIs from the ROI Manager to update the overlay on the original image
			roiManager("Show All");
selectWindow(C1_dupe_title);
		    // Clear any previous Results/Summary windows.
			if (isOpen("Results")) close("Results");
			if (isOpen("Summary")) close("Summary");
		
			// Ensure no ROI is actively selected
			roiManager("Deselect");
			
			// Measure all ROIs currently in the ROI Manager to update the Results table
			roiManager("Measure");
			// Generate a new Summary table based on the updated Results table
			// Get the current number of ROIs.
			selectWindow(C1_dupe_title);
			roiCount = roiManager("count"); // Count number of cells
			imageName = getTitle();
			
			// Display this count in the Results table:
			run("Clear Results");
			setResult("Image", 0, imageName);
			setResult(C1_name, 0, roiCount);
			updateResults();
			
			// Save updated DAPI summary.
			selectWindow("Results");
			wait(100);
			saveAs("Results", resultsDir + File.separator + C1_name + "_summary_" + title +".csv");
			close("Results");
			wait(500);
			selectWindow("C" + C1_num + "-" + title);
			saveAs("Tiff", resultsDir2 + File.separator + C1_name + "_DAPI_ROI_" + title + ".tif");
			rename("C" + C1_num + "-" + title);			
			// ===== Nuclei + Target Colocalisation =====
			imageCalculator("AND create", "C" + C1_num + "-" + title,"C" + C2_num + "-" + title);
			if (isOpen("Result of C" + C1_num + "-" + title)) {
				wait(500);
				selectWindow("Result of C" + C1_num + "-" + title);
				run("Analyze Particles...", ap_options);
				
				selectWindow(coloc_dupe_title);
				roiManager("Show All");
				waitForUser("Check ROIs", 
		    			"Review or edit these ROIs in the ROI Manager. " +
		    			"You can add, delete, or merge them. When satisfied, click OK.");
		    	// Clear any current overlay from the active image.
				run("Remove Overlay");
				
				// Re-add the ROIs from the ROI Manager to update the overlay.
				roiManager("Show All");
		    	// Close old Summary/Results so they don't linger
				if (isOpen("Results")) close("Results");
				if (isOpen("Summary")) close("Summary");
		
		    	// Ensure no ROI is actively selected
				roiManager("Deselect");
				selectWindow(coloc_dupe_title);
				// Measure all ROIs currently in the ROI Manager to update the Results table
				roiManager("Measure");
				// Generate a new Summary table based on the updated Results table
				// Get the current number of ROIs.
				selectWindow(coloc_dupe_title);
				roiCount = roiManager("count"); // Count number of cells
				imageName = getTitle();
				
				// Display this count in the Results table:
				run("Clear Results");
				setResult("Image", 0, imageName);
				setResult(C2_name + "_coloc", 0, roiCount);
				updateResults();
				
				// Save updated DAPI summary.
				selectWindow("Results");
				wait(100);
				saveAs("Results", resultsDir + File.separator + C2_name + "_Coloc_summary_" + title +".csv");
				close("Results");
				wait(500);
				selectWindow("Result of C" + C1_num + "-" + title);
				saveAs("Tiff", resultsDir2 + File.separator + C2_name + "_Coloc_image_" + title + ".tif");
				close();
				close(C2_name + "_Coloc_image_" + title + ".tif");
				close("*");
			}
				
}	
			
			// Code to combine all the saved files into one summary file called combined_summary
concatSummaryFiles(resultsDir, C1_name +"_summary_", C1_name + "_summary_combined.csv");
concatSummaryFiles(resultsDir, C2_name + "_Coloc_summary_", C2_name + "_Coloc_summary_combined.csv");

// Call the function with an array of files
files = newArray(resultsDir + C1_name + "_summary_combined.csv",
                 resultsDir + C2_name + "_Coloc_summary_combined.csv");
combineSideBySide(resultsDir + "Combined_summary.csv", files);

function combineSideBySide(outputFile, files) {
    // Initialize variables to hold file contents and max lines
    fileContents = newArray(files.length);
    maxLength = 0;

    // Load each file's contents as a single string
    for (i = 0; i < files.length; i++) {
        fileContents[i] = File.openAsString(files[i]);
        lines = split(fileContents[i], "\n");
        if (lines.length > maxLength) {
            maxLength = lines.length;
        }
    }

    // Create combined content
    combinedContent = "";
	for (i = 0; i < maxLength; i++) {
	    row = "";
	    for (j = 0; j < fileContents.length; j++) {
	        lines = split(fileContents[j], "\n");
	        if (i < lines.length) {
	            currentLine = trim(lines[i]);
	            // Skip truly empty lines if you want
	            if (currentLine == "") {
	                currentLine = "";
	            }
	            row += currentLine;
	        }
	        if (j < fileContents.length - 1) {
	            row += ",";
	        }
	    }
	    // Optionally skip a row if it is entirely blank
	    if (trim(row) != "") {
	        combinedContent += row + "\n";
	    }
	}

    // Save combined content to the output file
    File.saveString(combinedContent, outputFile);
}


function concatSummaryFiles(dir, prefix, outputFileName) {
    fileList = getFileList(dir);
    outputFile = dir + outputFileName;

    // Create or clear the output file
    File.saveString("", outputFile);

    firstFile = true;
    for (i = 0; i < fileList.length; i++) {
        if (startsWith(fileList[i], prefix)) {
            path = dir + fileList[i];
            fileContent = File.openAsString(path);

            // Split the file content into lines
            lines = split(fileContent, "\n");
            if (firstFile) {
                // Keep the header for the first file
                contentToAppend = "";
                for (j = 0; j < lines.length; j++) {
                    if (lengthOf(trim(lines[j])) > 0) { // Skip empty lines
                        contentToAppend += lines[j] + "\n";
                    }
                }
                firstFile = false;
            } else {
                // Skip the first line (header) for subsequent files
                contentToAppend = "";
				for (j = 0; j < lines.length; j++) {
				    if (j == 0 && lines[j] == "Summary Data") {
				        continue; // Skip the "Summary Data" header.
				    }
				    if (lengthOf(trim(lines[j])) > 0) {
				        contentToAppend += lines[j] + "\n";
				    }
				}
            }

            // Append content only if it's not empty
            if (lengthOf(contentToAppend) > 0) {
                File.append(contentToAppend, outputFile);
            }
        }
    }
}

close("*");
close("Results");
// Display a message with the directories where CSV files and ROI images were saved
showMessage("Files Saved", 
    "CSV files saved to: " + resultsDir + "\n" +
    "ROI images saved to: " + resultsDir2);
exit("Done");
			
			
			
			