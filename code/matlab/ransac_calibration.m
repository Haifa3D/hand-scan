function [R,t,valid, err] = ransac_calibration(centroids, radiuses, sn_1, sn_2, radius_range, draw_centroids)

centroids_1 = centroids{1};
centroids_2 = centroids{2};

radius_1 = radiuses{1};
radius_2 = radiuses{2};

radius_check = [radius_1 >= radius_range(1) & radius_1 <= radius_range(2) & ...
                radius_2 >= radius_range(1) & radius_2 <= radius_range(2)];

centroids_1 = centroids_1(:,radius_check);
centroids_2 = centroids_2(:,radius_check);

if(draw_centroids)
    figure;subplot(2,1,1);
    scatter3(centroids_1(1,:),centroids_1(2,:),centroids_1(3,:), 'MarkerFaceColor', 'red');
    hold on;
    scatter3(centroids_2(1,:),centroids_2(2,:),centroids_2(3,:), 'MarkerFaceColor', 'blue');
    xlabel('X(m)');
	ylabel('Y(m)');
    zlabel('Z(m)');
    title('Centroids - Original');
    legend(strcat("Centroids ", sn_1), strcat("Centroids ", sn_2), 'FontSize', 12);
end

centers_centroid_1 = mean(centroids_1,2);
Delta_1 = centroids_1 - centers_centroid_1;

centers_centroid_2 = mean(centroids_2,2);
Delta_2 = centroids_2 - centers_centroid_2;

[U,S,V] = svd(Delta_2*transpose(Delta_1));

R = U*transpose(V);
t = centers_centroid_2-R*centers_centroid_1;

centroids_1 = R*centroids_1 + t;

if(draw_centroids)
    hold on;subplot(2,1,2);
    scatter3(centroids_1(1,:),centroids_1(2,:),centroids_1(3,:), 'MarkerFaceColor', 'red');
    hold on;
    scatter3(centroids_2(1,:),centroids_2(2,:),centroids_2(3,:), 'MarkerFaceColor', 'blue');
    xlabel('X(m)');
	ylabel('Y(m)');
    zlabel('Z(m)');
    title('Centroids - Transformed');
    legend(strcat("Transformed centroids ", sn_1), strcat("Centroids ", sn_2), 'FontSize', 12);
end

valid = sum(radius_check)/length(radius_check) * 100;
err = sum(vecnorm(centroids_1 - centroids_2,2).^2)/sum(radius_check);

end