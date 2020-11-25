function denoised_pc = pc_guided_filter(ptCloud, radius, e)
    points = ptCloud.Location;
    normals = ptCloud.Normal;
    if(numel(normals) < ptCloud.Count)
        normals = pcnormals(ptCloud);
    end
    Idx = rangesearch(points,points,radius);
    C    = cell(ptCloud.Count,1);
    C(:) = {points};
    N    = cell(ptCloud.Count,1);
    N(:) = {normals};
    epsilon    = cell(ptCloud.Count,1);
    epsilon(:) = {e};
    ind = 1:ptCloud.Count;
    ind = num2cell(ind.');
    q_and_n = cell2mat(cellfun(@p_to_q,Idx,C, N,epsilon, ind,'uni',false));
    new_points = q_and_n( ~any(isinf( q_and_n ), 2 ),1:3);
    new_normals = q_and_n( ~any(isinf( q_and_n ), 2 ),4:6);
    denoised_pc = pointCloud(new_points, 'Normal', new_normals);
end

function q_and_n = p_to_q(nearest_neighbors,points, normals, e,index)
    q = [Inf Inf Inf];
    n = [Inf Inf Inf];
    p_i = points(index,:);
    n_i = normals(index,:);
    p_i_neighbors = points(nearest_neighbors,:);
    threshold = 3;
    if(size(p_i_neighbors,1)>threshold)
        sigma = cov(p_i_neighbors);
        [V,~] = eig(sigma);
        n = V(:,1);
        mu = mean(p_i_neighbors);
        mu = mu.';
        A = sigma / (sigma + e * eye(3));
        b = mu - A * mu;
        q = A * p_i.' + b;
        q = q.';
        n = n.';
        if(atan2(norm(cross(n,n_i)), dot(n,n_i)) > pi/2)
            n = -n;
        end
    end
    q = double(q);
    n = double(n);
    q_and_n = [q,n];

end