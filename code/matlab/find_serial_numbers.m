function serial_numbers = find_serial_numbers(directory)
% serial_numbers return all the serial numbers of the cameras from which
% the point clouds were taken.
    Files=dir(directory);
    serial_numbers = [];
    for k=1:length(Files)
        FileNames=Files(k).name;
    	if(contains(FileNames,'.ply') & contains(FileNames,'_'))
            sn = split(FileNames, '_');
            if(contains(directory,'calibration'))
                sn = sn{1};
            else
                sn = sn{2};
            end
            sn = str2num(sn);
            if(sum(ismember(serial_numbers, sn))==0)
                serial_numbers = [serial_numbers(:); sn];
            end
        end
    end
    
    serial_numbers = sort(serial_numbers);  
    serial_numbers = serial_numbers.';    
        
end