# hand-scan
In this project we created a low-cost 3D scanner of hands for later fitting of prosthetic hands.

## Introduction


## Requirements
* MATLAB Computer Vision Toolbox
* 3 or more SR300 Intel depth cameras.
* (optional) python 3.6

## Dependencies
In order to use or edit the python code you'll need to download the `pyrealsense2` module for python using `pip`:
```
pip install pyrealsense2
```

## Usage Instructions
First, you have to capture the calibration depth images and the scans of the hand (called captures).

### Capture Depth Images
This is done using the 'capture_and_calibrate' in the python directory.
You can use the .exe file (with ot without the timer before the capturing), or the python code. In order to run
the python code you'll need to install the `pyrealsense2` module, as mentioned above.
First Of all, connect the cameras to the computer.
Once all the cameras are connected, you'll need to run the execution file from the command window.
Open the command window and change the current directory to the path where the execution file is at.
First, you'll need to calibrate the system. Remove any objects from the FOV of the cameras, and 
take the sphere connected to the stick. 
Once the sphere is in the FOV of the cameras (preferably held by a second person), run the following command (for 
the version without the timer, replace ``` calibrate_and_capture.exe ``` with ``` "calibrate_and_capture - no Timer.exe" ```- 
```
calibrate_and_capture.exe NAME --calibrate --calNum calNum
```
where - 
* NAME - you can insert any name here. It is only important for the captures part.
* calNum - the number of rounds of depth images capturing, used for the calibration process. It need to be large enough, \
but not bigger than 29. In each round 15 depth images are taken one after another.

To see the optional arguments, run the following command - 
```
calibrate_and_capture.exe --help
```
Once the app is running, you'll hear a beap sound in the start and the end of each round. Between these beeps, move the sphere \
slowly around, while it stays in the FOV of at least two cameras at any time (preferably).
After each round you'll see the captures you've taken from each camera for a short time.

Once you've done capturing the calibration depth images, a directory named "calibration" will be created, with all the depth images inside it.
(If you want to run a new calibration, run the calibration again with a different NAME, and copy the new calibration directory into the first directory.
The new name has to contain the word "calibration")


After you've done taking the depth images for the calibration, run the following command line - 
```
calibrate_and_capture.exe NAME --capture --capNum capNum --normals --timer timer
```
where - 
* NAME - the name of the directory where the captures will be saved.
* capNum - the number of rounds of depth images capturing. A number between 5 to 10 would be good.
* normals - add normals to the depth images. This is recommended, but not mandatory.
* timer - number of seconds to show in the countdown before taking an image.

again, to see the optional arguments, run the following command - 
```
calibrate_and_capture.exe --help
```
If you've change the source directory of the calibration directory, you'll need to use the same one for any captures directory 
that uses this calibration.

### How To Do a Good Calibration Process
Follow the following guiding lines in order to get a good calibration - 
* Try to keep most of the sphere in the FOV at least 2 cameras. \
In the calibration processing, depth images where the sphere cannot be found in the depth images \
from both cameras will be removed, and less data will be used.
* Try to capture the sphere in all of the areas of the FOVs, and not only in the middle.
* Capture many calibration capture rounds. A small number of captures will result less data, \
and some of it might not be used (because no sphere could be found). The default value is 29 - \
and it should be good. It might be longer - both the capturing and the processing time, but \
if you won't change the setup, the calibration process is done only one time.
* If anything changes in the setup, for example if one of the cameras moved even a little bit - \
Please run a new calibration. Prevoius calibration might give bad results.
* Before capturing any hand, please check if the calibration give good results using the control panel.

### How To Do a Good Capturing Process
Follow the following guiding lines in order to get good captures - 
* Rotate the setup at small angles. This will give better registration results.
* Run enough capture round so that the whole hand will be scanned. \
5 to 10 rounds shold be enough.
* If the hand is quite symmetrical, include the elbow in the captures (you can remove it later using the \
Plane-Cut GUI).
* Try to keep the hand as steady as you can so the hand will look the same (in term of angles beween the arm and the \
hand palm for example) in every capture round.


### Running The Algorithm

After you've done taking the calibration and captures depth images, you need to open the control panel.
If you have MATLAB (this GUI was created using MATLAB R2020a), you can run the ```run_algorithm_gui.mlapp```.
If not, install the app using the ```app_installer.exe```.
After the installation is done, open the ```hand_scan_3D``` app that is installed on your computer.
You'll see the following control panel - 
![alt text](https://github.com/Haifa3D/hand-scan/tree/main/images/application_gui.png?raw=true)

Press the HELP button (or the F1 key) for reading the instruction of using the control panel.

Our suggestion is that you'll run each step of the algorithm one after another, and before proceeding 
to the next step check the mid-results to see if they are good -
* Before running the alignment step, please check that the calibration results were good (in terms of low errors).
* Before running the registration step, please load one of the aligned point clouds (a/b/c/... .ply) and see if they are \
aligned correctly. Parts of the hand from differnet cameras will be colored in different colors for making this observation easier.
* After the alignment, run the denoising before registration, and load the denoised point clouds (a/b/..._denoised.ply) and see the results.
* In the regitration step, select the point clouds (depth images) which you think might give bad results (for example - noisy point clouds, \
scans where the hand moved, etc.)
* After the registration step run the denoising after registration.
* After the registration and denoising after registration, check if the results look similar to the scanned hand. If so\
 run the reconstruction step. To see the reconstruction results, open the file in Meshlab or any other application for viewing \
 mesh files.


#### Control Panel Outputs
In the bottom of the control panel you'll see a textbox where the output of the algorithm will be printed.
Most of it is what the algorithm is running at the moment, and some of it are relevant measurements - 
After the calibration process is done, several error calculations will be printed.
For each camera the following error calculations will be printed -
* Average Mean Error - the mean error between the inliers of the sphere and the found sphere model (using MSAC). \
The lower the number is, the found sphere model is more accurate.
* Average Radius Error - the difference between the average of the found sphere models and the real sphere radius \
(inserted as a parameter). The smaller it is the more simillar the found sphere models to the real sphere. \
This error can occur due to an error in the sphere radius measurement and inaccuracies of the camera. \
If this number is large, consider that some of the errors is significant and the results might be bad.

For each pair of cameras the following calculations will be printed -
* MSE - the mean square error between the sphere's centroids after the transformation. \
In general, low MSE error implies that the transformation is good, but to be sure, \
check the results of the alignment.
* Valid spheres - the percentage of found sphere that their radius was inside of the allowed radius range. \
for higher values there will be more data to process, but some sphere might not be accurate.

After the registration, the following error calculations will be printed - 
* 




