function new_ptCloud = trim_ptCloud(ptCloud, minDistance)
% trim_ptCloud trims a point cloud and returns a point cloud of 
% its biggest cluster based on euclidean distance.
% Input -
%   * ptCloud - input point cloud.
%   * minDistance - minimum distance between points from 
%     different clusters.
% Output - 
%   * new_ptCloud - point cloud of the biggest cluster.
    
    labels = pcsegdist(ptCloud,minDistance);
    
    biggest_cluster = mode(labels);
    inliers = labels==biggest_cluster;
    cluster_points = ptCloud.Location(inliers, :);
    normals = ptCloud.Normal;
    if(size(ptCloud.Normal,1)>0)
        normals = ptCloud.Normal(inliers, :);
    end
    color = ptCloud.Color(inliers, :);
    new_ptCloud = pointCloud(cluster_points,'Normal', normals,...
                             'Color', color);

end