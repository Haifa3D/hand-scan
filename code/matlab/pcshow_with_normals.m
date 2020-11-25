function pcshow_with_normals(ptCloud, jump)

x = ptCloud.Location(1:jump:end,1);
y = ptCloud.Location(1:jump:end,2);
z = ptCloud.Location(1:jump:end,3);
u = ptCloud.Normal(1:jump:end,1);
v = ptCloud.Normal(1:jump:end,2);
w = ptCloud.Normal(1:jump:end,3);
figure
pcshow(ptCloud);
title('Point Cloud With Normals');
hold on;
quiver3(x,y,z,u,v,w);
hold off;
end