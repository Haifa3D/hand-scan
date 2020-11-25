function combine = pc_icp_registration(captures_dir, averaging, merge_size, serial_numbers)
    tic;
    theta = 10;
    minDistance = 0.02;
    Files = dir(captures_dir);
    combine = {};
    
    for sn = serial_numbers
        sn_pc = {};
        for k=1:length(Files)
            FileNames=Files(k).name;
            if(contains(FileNames, num2str(sn)))
                ptCloud = pcread(strcat(captures_dir,'\\',FileNames));
                ptCloud = trim_ptCloud(ptCloud, minDistance);
                sn_pc = {sn_pc{:},ptCloud};
            end
        end
        one_camera_combine = chain_registration(sn_pc, averaging, merge_size,theta);
        combine = {combine{:}, one_camera_combine};
        disp(sn);
    end
    
    toc;
end