function red_green_pc = pcinoutliers(ptCloud, inliers)
outliers = ~inliers;
red_green_pc = pointCloud(ptCloud.Location);
red_green_pc.Color = uint8(zeros(ptCloud.Count,3));

green = zeros(sum(inliers),3);
green(:,2) = 255;
red = zeros(sum(outliers),3);
red(:,1) = 255;

red_green_pc.Color(inliers, :) = green;
red_green_pc.Color(outliers, :) = red;

end