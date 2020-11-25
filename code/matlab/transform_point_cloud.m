function transformed_ptCloud = transform_point_cloud(ptCloud, R, t)
% transform_point_cloud transforms a point cloud using R and t.
% Input - 
%   * ptCloud - a point cloud.
%   * R - Rotation matrix.
%   * t - translation vector.
% Output -
% * transformed_ptCloud - the transformed point cloud.

    fixed_pointscolor = ptCloud.Color;
    points = ptCloud.Location;
    normals = ptCloud.Normal;
    points = (R*points.' + t).';
    if(size(normals,1)>0)
        normals = normals * R.';
    end
    transformed_ptCloud = pointCloud(points, 'Color', fixed_pointscolor, ...
        'Normal', normals);
end