function merged_ptCloud =  merge_point_clouds(fixed, moving, gridStep, SameColor)
% merge_point_clouds merged two point clouds.
% Input - 
%   * fixed - first point cloud.
%   * moving - second point cloud.
%   * gridStep - specifies the size of the 3-D box filter.
%   * SameColor - if false, than the fixed point cloud is colored with a
%   random color.


if(~SameColor)
    fixed = color_point_clouds(fixed);
end

merged_ptCloud = pcmerge(fixed, moving, gridStep);

end