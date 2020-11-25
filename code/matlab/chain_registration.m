function [combined_cloud,error] = chain_registration(gui_app,ptClouds, gridStep, ...
    error_threshold, InlierRatio)
    moving = ptClouds{1};
    error = [];
    for i = 2:length(ptClouds)    
        if(check_if_stop_running(gui_app))
            throw(MException());
        end
        fixed = ptClouds{i};
        [combine, reg_err] = reg2pc(gui_app, fixed ,...
            moving,gridStep, InlierRatio);
        if(reg_err <= error_threshold)
            error = [error,reg_err];
            moving = combine;
        else
            error = [error,-reg_err];
            if(sum(error>0)==0) % no good registration was made yet
                moving = fixed;
            end

        end
    end
    if(sum(error>0)==0)
        [~,index] = min(abs(error));
        combined_cloud = reg2pc(ptClouds{index} ,...
            ptClouds{index+1},gridStep, InlierRatio);
    else
        combined_cloud = moving;
    end
end