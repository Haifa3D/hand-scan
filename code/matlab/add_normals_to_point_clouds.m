function add_normals_to_point_clouds(directory, K)
    Files = dir(directory);
    for file=3:length(Files)
        if(contains(Files(file).name,'.ply'))
            pc_name = strcat(directory,'\',Files(file).name);
            ptCloud = pcread(pc_name);
            if(size(ptCloud.Normal,1) == 0)
                normals = pcnormals(ptCloud, K);
                X = ptCloud.Location;
                direction = sign(sum(X.*normals,2));
                direction(direction==0) = 1;
                direction = -1 * direction;
                normals = direction.*normals;
                ptCloud.Normal = normals;
                pcwrite(ptCloud, pc_name);
            end
            
        end
        
    end
end