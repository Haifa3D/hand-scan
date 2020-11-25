function sPtCloud = scale_pc(ptCloud, mm_to_meters)
% mm_to_meters true - scale from mm to meters
% mm_to_meters false - scale from meters to mm

X = ptCloud.Location;
if(mm_to_meters)
    X = X / 1000;
else
    X = X * 1000;
end

sPtCloud = pointCloud(X, 'Normal', ptCloud.Normal);

end