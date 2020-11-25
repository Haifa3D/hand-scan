function ptClouds = register_point_clouds(captures_dir, serial_numbers, R, t, varargin)
% register_point_clouds stitches point clouds using the extrinsic
% transformation R and t between the cameras.
% Input - 
%   * captures_dir - path of the directory where the point clouds are
%   saved.
%   * serial_numbers - serial numbers of the cameras.
%   * R - cell array of the rotation matrices between the cameras.
%   * t - cell array of the translation vectors between the cameras. 
% Optional input -
%   * DrawPointCloud - draw the found sphere in the point cloud (T/F).
%   * SameColor - if this value is False, then each pointcloud from
%   different cameras is colored with (randomly) different (uniform) color.
%   * TrimPointCloud - only take the biggest cluster in the point cloud
%   based on euclidean distance.
%   * minDistance - minimum distance between points from different 
%   clusters.
%   * gridStep - points within a 3-D box in the size of gridStep are merged
%   to a single point.
% Output - 
%   * ptClouds - cell array of the registered point clouds.    

ptClouds = {};

p = inputParser;
addRequired(p,'CapturesDir',@(s)isstring(s));
addRequired(p,'SerialNumbers',@(x) validateattributes(x,{'numeric'},{'positive'}));
addRequired(p,'R',@(x)iscell(x));
addRequired(p,'t',@(x)iscell(x));

addParameter(p,'DrawPointCloud',false, @(x)islogical(x));
addParameter(p,'SameColor',true, @(x)islogical(x));
addParameter(p,'TrimPointCloud',true, @(x)islogical(x));
addParameter(p,'minDistance',0.5,@(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(p,'gridStep',1e-3,@(x) isnumeric(x) && isscalar(x) && (x>0));

parse(p, captures_dir,serial_numbers,R,t, varargin{:});
res = p.Results;

CapturesDir = res.CapturesDir;
SerialNumbers = res.SerialNumbers;
R = res.R;
t = res.t;
DrawPointCloud = res.DrawPointCloud;
SameColor = res.SameColor;
TrimPointCloud = res.TrimPointCloud;
minDistance = res.minDistance;
gridStep = res.gridStep;

% find num of rounds
Files=dir(CapturesDir);
max_round_letter = 'a';

for k=1:length(Files)
    	FileName=Files(k).name;
    	if(contains(FileName, 'ply'))
            split_str = split(FileName,'_');
            letter = split_str{1};
            if letter > max_round_letter
                max_round_letter = letter;
            end
        end
end

lcLetters = 'a':max_round_letter;

for round_letter = lcLetters            
%     show_waitbar(false,0.25 * 1 /length(lcLetters), strcat("Registering -  ", round_letter, '.ply'));
    ptCloud_moving = pcread(strcat(CapturesDir,'\\',round_letter,'_', num2str(SerialNumbers(1)), '.ply'));
    if(~SameColor)
        ptCloud_moving = color_point_clouds(ptCloud_moving);
    end
    for i = 2:(length(SerialNumbers))
        sn_fixed = num2str(SerialNumbers(i));
        
        ptCloud_fixed = pcread(strcat(CapturesDir,'\\',round_letter,'_', sn_fixed, '.ply'));
        ptCloud_moving = transform_point_cloud(ptCloud_moving, R{i-1}, t{i-1});
        ptCloud_moving = merge_point_clouds(ptCloud_fixed,ptCloud_moving, gridStep, SameColor);
        
    end
    
    if(TrimPointCloud)
        ptCloud_merged = trim_ptCloud(ptCloud_moving, minDistance);
    else
        ptCloud_merged = ptCloud_moving;
    end
    
    if(DrawPointCloud)
        figure();
        if(TrimPointCloud)
            subplot(1,2,2);
            pcshow(ptCloud_merged);
            title('Merged Point Cloud - Trimmed');
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            view(2);
            subplot(1,2,1);
        end
        pcshow(ptCloud_moving);
        title('Merged Point Cloud - Non-trimmed');
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        view(2);
    end
    
    pcwrite(ptCloud_merged, strcat(CapturesDir,'\\',round_letter, '.ply'));
    
    ptClouds = {ptClouds{:}, ptCloud_merged};
end

    
end