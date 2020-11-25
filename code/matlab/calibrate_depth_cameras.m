function [R,t,valid, calibration_mse,ransac_mmse, ransac_radius_errors] = ...
    calibrate_depth_cameras(gui_app, calibration_dir, serial_numbers, ...
    radius, radius_error, varargin)
% calibrate_depth_cameras find extrinsic calibration between numerous
% cameras.
% Input - 
%   * calibration_dir - directory in which the point clouds are saved.
%   * serial_numbers - serial numbers of the cameras from which the point
%   clouds were captured.
%   * radius - radius of the sphere in the point clouds.
%   * radius_error - allowed error in the radius of the found sphere.
% Optional Input - 
%   * MaxNumTrials - Maximum number of random trials for finding inliers.
%   * MaxDistance - maximum distance between inlier points and the sphere.
%   in meters. default value is 0.01.
%   * DrawSphere - draw the found sphere in the point cloud (T/F). default
%   value is false.
%   * DrawCenter - draw the center point of the sphere (T/F). default value 
%   is false.
%   * DrawGlob - draw the inlier points of the sphere (T/F). default value 
%   is false.
%   * DrawCentroids - draw the centroids of the spheres that were found
%   before and after the transformation (T/F). default value is false.
%   * OnlyValid - draw only the spheres that has a valid radius (T/F).
%   default value is false.
%   * numOfTries - number of tries to find a sphere.defualt value is 5.
% Output - 
%   * R - cell array of the rotation matrices between the cameras. R{1} is
%   the rotation matrix from cameras #1 to camera #2 and so on.
%   * t - cell array of the translation vectors between the cameras. t{1} 
%   is the translation vector from cameras #1 to camera #2 and so on.
%   * mse - cell array of the mean sqaure errors of the transformation.
%   * valid - cell array of the percentage of valid spheres that where 
%   found.

R = {};
t = {};
valid = [];
calibration_mse = [];

p = inputParser;

addRequired(p,'GuiApp');
addRequired(p,'CalibrationDir',@(s)isstring(s));
addRequired(p,'SerialNumbers',@(x) validateattributes(x,{'numeric'},{'positive'}));
addRequired(p,'Radius',@(x) isnumeric(x) && isscalar(x) && (x > 0));
addRequired(p,'RadiusError',@(x) isnumeric(x) && isscalar(x) && (x > 0));

addParameter(p,'MaxNumTrials',1e5, @(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(p,'MaxDistance',0.01, @(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(p,'DrawSphere',false, @(x)islogical(x));
addParameter(p,'DrawCenter',false, @(x)islogical(x));
addParameter(p,'DrawGlob',false, @(x)islogical(x));
addParameter(p,'DrawCentroids',false, @(x)islogical(x));
addParameter(p,'OnlyValid',true, @(x)islogical(x));
addParameter(p,'numOfTries',5, @(x) isnumeric(x) && isscalar(x) && (x > 0));

parse(p,gui_app, calibration_dir, serial_numbers, radius, radius_error, varargin{:});
res = p.Results;

gui_app = res.GuiApp;
CalibrationDir = res.CalibrationDir;
SerialNumbers = res.SerialNumbers;
Radius = res.Radius;
RadiusError = res.RadiusError;
radius_range = [(Radius-RadiusError), (Radius+RadiusError)];
MaxNumTrials = res.MaxNumTrials;
MaxDistance = res.MaxDistance;
DrawSphere = res.DrawSphere;
DrawGlob = res.DrawGlob;
DrawCentroids = res.DrawCentroids;
DrawCenter = res.DrawCenter;
OnlyValid = res.OnlyValid;
numOfTries = res.numOfTries;


[centroids, radiuses, ransac_mmse, ransac_radius_errors] = ...
    find_centers_and_radiuses(gui_app, CalibrationDir, SerialNumbers, radius_range,MaxDistance...
    ,MaxNumTrials, DrawSphere, DrawGlob, DrawCenter, OnlyValid, numOfTries);


for i = 2:(length(SerialNumbers))
    sn_1 = num2str(SerialNumbers(i-1));
    sn_2 = num2str(SerialNumbers(i));
    if(check_if_stop_running(gui_app))
        throw(MException());
    end
    [R1, t1, valid1, calib_mse1] = ransac_calibration({centroids{i-1}, centroids{i}}, {radiuses{i-1}, radiuses{i}}, sn_1, sn_2, radius_range, DrawCentroids);

    R = {R{:},R1};
    t = {t{:},t1};
    valid = [valid, valid1];
    calibration_mse = [calibration_mse, calib_mse1];
    
end

save(strcat(calibration_dir,'\\R.mat'),'R');
save(strcat(calibration_dir,'\\t.mat'),'t');
end