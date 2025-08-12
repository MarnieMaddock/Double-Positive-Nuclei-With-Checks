# Double Positive Nuclei Automated Analysis

This is an open-source, FIJI macro that automatically counts cells that have co-localisation of a specific target within the nuclei. It is very Similar to https://github.com/MarnieMaddock/Double-Positive-Nuclei - however there is the option for the regions of interest to be managed or edited during the macro to ensure accuracy.

## How It Works

1. **Folder of TIFF Images**: All images need to be saved as a TIFF in a folder on your computer. To automatically convert .lif files to TIFF, see https://github.com/MarnieMaddock/Lif-to-Tif.
2. **Add Adaptive Threshold Plugin**: Install Adaptive Threshold Plugin using instructions given here: https://sites.google.com/site/qingzongtseng/adaptivethreshold. Ensure when naming the plugin use adaptiveThr (check capitalisation)
3. **Open macro in FIJI**: Drag and Drop Double-Positive-Nuclei-With-Checks.ijm into the FIJI console.
4. **Run**: Press Run on the macro.
5. **Customise Analysis**: The macro will ask to select the folder containing TIFF images to be analysed. A pop-up box will appear to guide users into specifying the channels that correspond to the nucleus vs target, and the names of the targets e.g. DAPI and SOX10. The macro will propmt the user to specify the pre-processing filters and settings they prefer.
6. **Semi-Automated Analysis**:  Co-localisation counts and ROI images will be saved in the selected folder. There are pause steps included so the user can delete/add ROIs to the image.
7. **Output**:  Count results are saved as a .csv file. Per image results are saved (i.e. nucelus counts and co-localisation counts). A "Combined_summary" file includes all the counts for each image nuclei and co-localistaion in a summarised format. Regions of interest that are counted are saved to the ROI_images folder. 

## Analysis Steps

1. **Image Pre-processing**:
   - Median Filter: To remove speckles.
   - Unsharp Mask: To enhance edge contrast of nuclei.
   - Adaptive Threshold: To threshold the nuclei or target. Note the defaults of Mean = 341 then = -49. The numbers specified can be optimised for your own image by going to Plugins --> Adaptive Thresholding, then changing the numbers specified in the macro.
   - Watershed: Segments nearby nuclei.
2. **Count Nuclei**
3. **Review ROIs in the ROI Manager**
   - Select an ROI object e.g. 0001-0011 to highlight it on the image.
   - Using the side panel of the ROI manager, the user can add, or delete ROIs.
   - Click OK when done.
4. **Count Co-localised Nuclei/target**
   - The nuclei and target channel are superimposed using the Image Calculator, outputting an image that only inlcludes overlapping pixels.
   - Count co-localised cells.
5. **Review ROIs in the ROI Manager**
6. **Save Results**
   - Save counts and region of interest images
7. **Calculate Number of double-positive cells %**
   - (Nuclei Positive Cells/Co-localised Positive Cells) * 100

## Feedback and Support
If you encounter any issues or have suggestions, feel free to:

- Open an issue on this repository
- [Email Us](mlm715@uowmail.edu.au)

  
## License
Double-Positive-Nuclei project is licensed under the MIT License. See [LICENSE](https://github.com/MarnieMaddock/Double-Positive-Cells-With-Checks/blob/main/LICENSE) for details.

---- 
