function [combined_cloud, error, tform] = reg2pc(gui_app, ...
            moving, fixed, gridStep, InlierRatio)

    moving_down = pcdownsample(moving,'gridAverage',gridStep);
    fixed_down = pcdownsample(fixed,'gridAverage',gridStep);
    
    %finding an initial transformation using downsampled point clouds for
    %fast results
    if(check_if_stop_running(gui_app))
        throw(MException());
    end
    [tform, ~, ~] = pcregistericp(moving_down, fixed_down, ...
        'Metric','pointToPoint', 'InlierRatio', InlierRatio, ...
        'Tolerance', [1e-6, 1e-6],'Extrapolate',false,...
        'MaxIterations', 1e4, 'Verbose', false);
    if(check_if_stop_running(gui_app))
        throw(MException());
    end
    % getting a more accurate result using the original point clouds
    [tform, ptCloudAligned, error] = pcregistericp(moving, fixed, ...
        'Metric','pointToPoint', 'InlierRatio', InlierRatio, ...
        'Tolerance', [1e-6, 1e-6],'Extrapolate',false,...
        'MaxIterations', 100, 'Verbose', false, 'InitialTransform', tform);
    combined_cloud = pcmerge(fixed, ptCloudAligned, 1e-3);
    
end