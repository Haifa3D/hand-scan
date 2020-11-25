function [pc_inliers,pc_outliers, inliers, outliers] = pc_find_boundry_points(ptCloud, radius, th)
X = ptCloud.Location;
normals = ptCloud.Normal;
if(numel(normals) < ptCloud.Count)
        normals = pcnormals(ptCloud);
end
Idx = rangesearch(X,X,radius);
X_new = [];
outliers = false(size(X,1),1);
mean_of_neighbors = cell2mat(cellfun(@(x) find_mean(X(x,:)),Idx,'uni',false));

outliers = vecnorm(mean_of_neighbors-X,2,2) > th;
inliers = ~outliers;
pc_outliers = pointCloud(X(outliers,:), 'Normal', normals(outliers,:));
pc_inliers = pointCloud(X(inliers,:), 'Normal', normals(inliers,:));

end

function mean_point = find_mean(points)
if(size(points,1) == 1)
    mean_point = points;
else
    mean_point = mean(points);
end

end