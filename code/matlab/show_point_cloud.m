function show_point_cloud(ax,ptCloud,A,B,C,x,y,z, show_arrow)

    pcshow(pointCloud(ptCloud.Location), 'Parent',ax);
    xlabel(ax,'X(m)');
    ylabel(ax,'Y(m)');
    zlabel(ax,'Z(m)');
    if(show_arrow)
        hold(ax,'on');
        min_mesh = min([ptCloud.XLimits(1), ptCloud.YLimits(1), ptCloud.ZLimits(1)]);
        max_mesh = max([ptCloud.XLimits(2), ptCloud.YLimits(2), ptCloud.ZLimits(2)]);

        s = sqrt(A^2+B^2+C^2);
        q = quiver3(ax,x,y,z,A/s*max_mesh,B/s*max_mesh,C/s*max_mesh,'Linewidth',5);
        set(q,'MaxHeadSize',1);set(q,'Color',[1 0 0]);
        hold (ax, 'off');
    end
    
    
end