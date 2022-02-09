About
=====

Morphoscript analyzes the organization level of sarcomeres in cardiomyocytes and measure their local orientation, spacings.
It is developped as a matlab application.
A python jupyter notebook is also available for explaining the main concepts used by the software.
It should work for version of matlab 2017a or higher.
More details could be found in our article:
https://doi.org/10.1093/bioinformatics/btab400


Install
=======

There are two ways you can use morphoscript:
+ Install the application using the install app icon in the APPS menu of matlab : click Install app, and select the morphoscript application in your installed folder.
+ run the files using script  (see script_example.m)
After downloading the project, 

Quick start
===========

In the APPs menu, there is a now a new icone for morphoscript.
If you click on it you will be asked for the files you wnat to analyze.
You can make your first try by selecting the examples provided
Here are the different menus now available:

## Set save directory 

Choose the paths where you want your results to be saved 
(TYPES OF RESULTS?)

## Make Masks

If the pixel size can not be read from the image metadata,  a window will open asking for the pixelsize (this is the case for the test1.tif, where the pixel
size to be entered is 0.06 µm).

The image is now presented to the user, if it is a colored image, one can choose the best channel for doing the analysis (if "all" is selected, the image used for the analysis will be the average on the three channels)


Three new possibilities for making the mask
+ manual: the contour of cells is drawn by hands, you can add as many cells as wished
+ automatic : an automatic detection of the contour can be attempted using an entropy filter an opening to remove small non objects size (whose size can be adjusted) and a disk closing of the cell to remove holes in the mask, here also the size can be adjusted
+ combination : a rough contour can be drawn on which the automatic algorithm is then run.



## check masks

Check if all the files added in the selected files section do possess a corresponding mask necessary for a subsequent analysis. 


## Shape Analysis

This menu is used for measuring geometric parameters of the cell characterizing cell spreading as well as the intensity of the sarcomeric structure, 
4 parameters can be visualized:
+ Otsu ie the mask with an automatic threshold delineating the sarcomeres
+ compactness showing the boundaries of the mask
+ Bounding box of the cell mask
+ Ellipse, which will show the ellipse with the same second moment as the cell's mask

The original button enables to go back to the bare display of the cell of interest. The save button will save the results.
Data are saved to disk in a file named '*_maski_ShapeAnalysis.mat', where '*' represents the name of your image, i will be the cell number on your image.
In this mat file, you will get the following variables:
{'MaskPixels','OtsuPixels','MaskMicrons','OtsuMicrons','Coverage','MeanImageIntensity','MaxImageIntensity','MeanProteinIntensity','Compactness,'Roundness','Rectangularity','Elongation','Ellipsoidal','Eccentricity', 'MeanBackCellintensity'}

## Fourier Analysis

First, check that the pixel size is correct, if not you can easily set the appropriate one. Then 3 parameters can be adjusted for the analysis
+ Window Size : size of the interrogation window for the Fourier Transform Calculation
+ Overlap of the window
+ Threshold : which will determine if the intensity of the peak found in Fourier corresponding to the sarcomere structure is intense enough to aknowledge the presence of a real structure.
  
  Two possibilities are available :
  + Run by hand, for each window under the cell mask the intermediate fourier images and corresponding intensity curve will be displayed which enables the user to crosscheck absolutely all the results
  + Run model, will run the complete analysis automatically with no display, but the user will still have the possibility to correct some window by clicking on the edit button and selecting the window of interest, it will open the intermediate Fourier display.

After a complete analysis, the order parameter, the standard deviation on orientation and the spacing of the sarcomeres are displayed. You can save the results and go to the next cell.



# Authors

Tess Homan (t.a.m.homan@tue.nl)
Hélène Delanoë-Ayari (helene.ayari@univ-lyon1.fr)
Adrien Moreau ( adrien.moreau@outlook.com)

# License

GNU General Public License v3.0
