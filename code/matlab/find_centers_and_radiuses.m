function [centroids, radiuses, mmses, radius_errors] = ...
         find_centers_and_radiuses(gui_app, calibration_dir, ...
         serialNumbers, radius_range,maxDistance,MaxNumTrials, ...
         draw_sphere, draw_glob, draw_center, only_valid, numOfTries)
% find_centers_and_radiuses find the centers and radiuses of the spheres
% that were find in given point clouds that were captured from several
% depth cameras.
% Input - 
%   * calibration_dir - the path of the directory were the point clouds
%   where the point clouds are saved.
%   * serialNumbers - serial numbers of all the cameras from which the
%   point clouds were captured.
%   * radius_range - range of allowed radiuses for the sphere.
%   * maxDistance - maximum distance between inlier points and the sphere.
%   * MaxNumTrials - Maximum number of random trials for finding inliers.
%   * draw_sphere - draw the found sphere in the point cloud (T/F).
%   * draw_glob - draw the inlier points of the sphere (T/F).
%   * draw_center - draw the center point of the sphere (T/F).
%   * only_valid - draw only the spheres that has a valid radius (T/F).
%   * numOfTries - number of tries to find a sphere.
%   Output - 
%   * centroids - cell aray of the centroids of the spheres for each camera.
%   * radiuses - cell aray of the radiuses of the spheres for each camera.

centroids = {};
radiuses = {};
mmses = [];
radius_errors = [];
Files=dir(calibration_dir);

for sn = serialNumbers
    
    print_text(gui_app, "Searching spheres for camera - " + num2str(sn) + ".");
    centroids_1 = [];
    radius_1 = [];
    mmses_1 = [];
    radius_errors_1 = [];
    
    for k=1:length(Files)
    	FileNames=Files(k).name;
        if(check_if_stop_running(gui_app))
            throw(MException());
        end
    	if(contains(FileNames, num2str(sn)))
        	ptCloud = pcread(strcat(calibration_dir,'\\',FileNames));
            if(draw_sphere)
                [model,inlierIndices] = pcfitsphere(ptCloud,maxDistance, 'MaxNumTrials', MaxNumTrials);
            end
            [sphere, mmse, radius_error] = find_sphere(ptCloud,maxDistance,radius_range, MaxNumTrials, numOfTries);
            in_radius_range = sphere.Radius >= radius_range(1) & sphere.Radius <= radius_range(2);
            if(draw_sphere & (~only_valid | (only_valid & in_radius_range)))
                figure;pcshow(ptCloud);title(FileNames);
                xlabel('X(m)');
                ylabel('Y(m)');
                zlabel('Z(m)');
                cap_num = split(FileNames, '_');
                cap_num = cap_num(2);
                cap_num = split(cap_num, '.');
                cap_num = cap_num(1);
                title(strcat("Camera - ", sn, ", #",cap_num));
                hold on;
                s = plot(model);
                alpha(s,.3);
                hold on;
                if(draw_center)
                    plot3(model.Center(1), model.Center(2), model.Center(3),'o','Color','r','MarkerSize',10, 'MarkerFaceColor', 'green');
                end
            end
            if(draw_glob)
                globe = select(ptCloud,inlierIndices);
                figure;
                xlabel('X(m)');
                ylabel('Y(m)');
                zlabel('Z(m)');
                title('Globe Point Cloud');
                pcshow(globe);
            
            end
        
            centroids_1 = [centroids_1,(sphere.Center)'];
            radius_1 = [radius_1,sphere.Radius];
            if(in_radius_range)
                mmses_1 = [mmses_1, mmse];
                radius_errors_1 = [radius_errors_1, radius_error];
            end
        end
    end
    centroids = [centroids(:)',{centroids_1}];
    radiuses = [radiuses(:)',{radius_1}]; 
    mmses = [mmses,mean(mmses_1)]; 
    radius_errors = [radius_errors,mean(radius_errors_1)];
    
    
end

end