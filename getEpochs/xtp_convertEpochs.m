% xtp_convertEpochs.m
%
% given a cell array with each cell containing a Nx2 matrix of start and
% end times for epochs, and assuming the times are seconds counted from
% 7/30/07 00:00:00, converts all these values to datenumbers, retaining the
% same structure.
%
function outepochs = xtp_convertEpochs(inepochs)

db = size(inepochs);

for b = 1:db(1)
    for d = 1:db(2)
        if inepochs{b,d} ~= 0
            col1 = datestr((double(inepochs{b,d}(:,1))/(3600*24))+datenum('07/30/2007 00:00:00', 'mm/dd/yyyy HH:MM:SS'), 'mm/dd/yyyy HH:MM:SS');
            col2 = datestr((double(inepochs{b,d}(:,2))/(3600*24))+datenum('07/30/2007 00:00:00', 'mm/dd/yyyy HH:MM:SS'), 'mm/dd/yyyy HH:MM:SS');
            outepochs{b,d} = {col1 col2};
            message = ['done with b=' num2str(b) ' and d=' num2str(d)];
            disp(message);
            clear col1;
            clear col2;
        end
    end
end
end
