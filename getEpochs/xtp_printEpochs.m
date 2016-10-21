% xtp_printEpochs.m
%
%given the output of xtp_getEpochs, this function prints to a text file
%

% Change log
% Ver Date      Person          Change
% 1.0 10/19/08  S. Williams     Created
% 1.1 10/20/08  S. Williams 
% 1.2 10/24/08  S. Williams     used input argument 1 as output filename,
%                               removed 'to' between start and end times

function status = xtp_printEpochs(epochs, filename)

if nargin < 2
    filename = [inputname(1) '.txt'];
end
fid = fopen(filename, 'wt');
if fid == -1
    message = ['Could not open file ' filename ' for writing.'];
    disp(message);
    status = fid;
    return;
else
    message = ['Writing output to ' filename];
    disp(message);
    db = size(epochs);
    for d=1:db(2)
        for b=1:db(1)
            fprintf(fid, 'Epochs for dose %d, bucket %d\n',d,b);
            if iscell(epochs{b,d})
                len = size(epochs{b,d}{1,1});
                len = len(1);
                for s=1:len
                    fprintf(fid,'%s %s\n', epochs{b,d}{1,1}(s,:), epochs{b,d}{1,2}(s,:));
                end
                fprintf(fid, '%d epochs total\n\n',len);
            end
        end
    end
end
fclose(fid);
status = 1;
end