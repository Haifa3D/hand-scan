function new_ptCloud = color_point_clouds(ptCloud)
    pointscolor=uint8(zeros(ptCloud.Count,3));
    pointscolor(:,1)= uint8(255*rand(1)*ones(ptCloud.Count,1));
    pointscolor(:,2)= uint8(255*rand(1)*ones(ptCloud.Count,1));
    pointscolor(:,3)= uint8(255*rand(1)*ones(ptCloud.Count,1));
    ptCloud.Color = pointscolor;
    new_ptCloud = ptCloud;
end