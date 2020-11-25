function [pc_new, inliers] = pcneighborsfilter(ptCloud, radius, percentage)
% pcradiusfilter applies a radius filter on a point cloud. points that has
% more neighbors in the specified radius near him than the threshold,
% counts as an inlier.
% Input - 
%   * ptCloud - the point cloud.
%   * radius - the radius in which to count the neighbors.
%   * percentage - the percentage on the points to remove.
% Output - 
%   * pc_new - the filtered point cloud.
%   * inliers - a logical array of the inliers.
X = ptCloud.Location;
normals = ptCloud.Normal;
if(numel(normals) < ptCloud.Count)
        normals = pcnormals(ptCloud);
end
Idx = rangesearch(X,X,radius);
X_new = [];
inliers = false(size(X,1),1);
nn = cell2mat(cellfun(@size,Idx,'uni',false));
nn = nn(:,2);

[nn_sort, I_nn_sort] = sort(nn);
max_index = round(percentage * numel(nn));

outliers = zeros(size(nn));
outliers(I_nn_sort(1:max_index))=true;
inliers = ~outliers;
X_new = X(inliers,:);
if(size(normals,1) >= size(inliers,1))
    normals = normals(inliers,:);
end
pc_new = pointCloud(X_new, 'Normal', normals);

end
