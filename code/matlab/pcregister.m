function ptCloud = pcregister(ptClouds, R,t,gridStep,SameColor)

    ptCloud_moving = ptClouds{1};

    for i = 2:length(ptClouds)
        ptCloud_fixed = ptClouds{i};
        ptCloud_moving = transform_point_cloud(ptCloud_moving, R{i-1}, t{i-1});
        ptCloud_moving = merge_point_clouds(ptCloud_fixed,ptCloud_moving, gridStep, SameColor);
    end
    
    ptCloud = ptCloud_moving;

end