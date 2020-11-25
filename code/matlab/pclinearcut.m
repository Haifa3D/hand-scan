function [pccut,inliers] = pclinearcut(ptCloud,x,y,z,A,B,C)
Location = ptCloud.Location;
normals = ptCloud.Normal;
if(numel(normals) < ptCloud.Count)
        normals = pcnormals(ptCloud);
end
X = Location(:,1);
Y = Location(:,2);
Z = Location(:,3);

inliers = A*(X-x)+B*(Y-y)+C*(Z-z)> 0;
X_new = Location(inliers,:);
normals_new = normals(inliers,:);
pccut = pointCloud(X_new, 'Normal', normals_new);
end