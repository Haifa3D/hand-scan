function plot_plane(ax,A,B,C,x,y,z,x_min,x_max,y_min,y_max)

v = [A, B, C];
w = null(v); % Find two orthonormal vectors which are orthogonal to v
x_ax = x_min:((x_max-x_min)/10):x_max;
y_ax = y_min:((y_max-y_min)/10):y_max;
[P,Q] = meshgrid(x_ax,y_ax); % Provide a gridwork (you choose the size)
X = x+w(1,1)*P+w(1,2)*Q; % Compute the corresponding cartesian coordinates
Y = y+w(2,1)*P+w(2,2)*Q; %   using the two vectors in w
Z = z+w(3,1)*P+w(3,2)*Q;
hold(ax,'on');
s=surf(ax,X,Y,Z);alpha(s,0.5);
hold(ax,'on');
end