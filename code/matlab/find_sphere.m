function [sphere, mmse, radius_error] = find_sphere(ptCloud,maxDistance,radius_range, MaxNumTrials, numOfTries)
% find_sphere finds a sphere in a point cloud using RANSAC algorithm.
% the function searches numerous times for a sphere with a known radius
% and returns the average sphere.
% Input - 
%   * ptCloud - Input point cloud.
%   * maxDistance - maximum distance between inlier points and the sphere.
%   * radius_range - range of allowed radiuses for the sphere.
%   * MaxNumTrials - Maximum number of random trials for finding inliers.
%   * numOfTries - number of tries to find a sphere.
% Output - 
%   * sphere - the average sphere of all the spheres that were found with 
%     a radius in the allowed radius range.

radius_sum = 0;
centers_sum = [0,0,0];
count = 0;
radius = 0;
center = [0,0,0];
mmse = 0;

PC_COUNT_MIN = 100;

if(ptCloud.Count >= PC_COUNT_MIN)
    for i = 1:numOfTries
        [model,~,~,mse] = pcfitsphere(ptCloud,maxDistance, 'MaxNumTrials', MaxNumTrials);
        in_radius_range = model.Radius >= radius_range(1) & model.Radius <= radius_range(2);
    
        if(in_radius_range)
            count = count + 1;
            mmse = mmse + mse;
            radius_sum = radius_sum+model.Radius;
            centers_sum = centers_sum+model.Center;
        end
    end
    if(count > 0)
    
        mmse = mmse / count;
        radius = radius_sum/count;
        center = centers_sum/count;
    end
end
radius_error = abs(radius - mean(radius_range));
sphere = sphereModel([center, radius]);

end