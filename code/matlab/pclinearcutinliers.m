function pc_inliers = pclinearcutinliers(ax,ptCloud,A,B,C,x,y,z)

axes(ax);
[pc_inliers,inliers] = pclinearcut(ptCloud,x,y,z,A,B,C);
red_green_pc = pcinoutliers(ptCloud, inliers);
pcshow(red_green_pc, 'Parent',ax);

hold(ax,'on');
xlabel(ax,'X(m)');
ylabel(ax,'Y(m)');
zlabel(ax,'Z(m)');

min_mesh = min([red_green_pc.XLimits(1), red_green_pc.YLimits(1), red_green_pc.ZLimits(1)]);
max_mesh = max([red_green_pc.XLimits(2), red_green_pc.YLimits(2), red_green_pc.ZLimits(2)]);

plot_plane(ax,A,B,C,x,y,z,...
    red_green_pc.XLimits(1),red_green_pc.XLimits(2),...
    red_green_pc.YLimits(1),red_green_pc.YLimits(2)...
    );
s = sqrt(A^2+B^2+C^2);
q = quiver3(ax,x,y,z,A/s*max_mesh,B/s*max_mesh,C/s*max_mesh,'Linewidth',5);
set(q,'MaxHeadSize',1);set(q,'Color',[0 0 1]);

hold (ax, 'off');
end