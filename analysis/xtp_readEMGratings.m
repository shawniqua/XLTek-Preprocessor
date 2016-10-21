function ppdata = xtp_readEMGratings(filename,ppdata)
% Adds EMG ratings to the metadata for each epoch.
%
% EXAMPLE: ppdata = stw_readEMGratings(filename,ppdata)
% assumes each row of filename is in format: [date starttime date endtime xxxx xxxx xxxxx xxxx xx]
% so that there are 5 groups of channels (can be more than 18) 
% and one row for each epoch


% CHANGE CONTROL
% Ver   Date        Person      Change
% 1.0   02/06/10    S. Williams Copied from script stw_readEMGratings,
%                               updated to check that start and end times
%                               match
% DONT FORGET TO UPDATE VERSION NUMBER BELOW

funcname = 'xtp_readEMGratings';
version = '1.0';

global XTP_GLOBAL_PARAMS

fid = fopen(filename);
raw = textscan(fid, '%19c %19c %s %s %s %s %s');
% raw = textscan(fid, '%s %s %s %s %s');
fclose(fid);

%% check epochs
ppdataepochs = [{ppdata.metadata.start}' {ppdata.metadata.end}'];

for epoch = 1:size(raw{1},1)
    raw{1}(epoch,:) = regexprep(raw{1}(epoch,:),'\t',' ');
    raw{2}(epoch,:) = regexprep(raw{2}(epoch,:),'\t',' ');
end
fileepochs = [cellstr(raw{1}) cellstr(raw{2})];

if ~isequal(ppdataepochs, fileepochs)
    ppdataepochs
    fileepochs
    disp('ERROR: PPdata was not updated because the epoch times do not match.')
    return
end

if XTP_GLOBAL_PARAMS.interactive
    fprintf(1,'WARNING: channels rated MUST be in the same order as the variable montage.');
end

%% reformat input EMG ratings
raw = raw(3:end);
for col = 1:5
%     mat1{col} = cell2mat(raw{col+3});
    mat1{col} = cell2mat(raw{col});
end
mat2 = cell2mat(mat1);
for epoch = 1:size(mat2,1)
    for ch = 1:size(mat2,2)
        emg(epoch,ch) = str2num(mat2(epoch,ch));
    end
end

%% assign ratings
numepochs = length(ppdata.metadata);
for ep = 1:size(emg,1)
    ppdata.metadata(ep).EMGratings = emg(ep,:);
end
for ep = size(emg,1)+1:numepochs
    ppdata.metadata(ep).EMGratings = zeros(1,size(emg,2));
end

%% leave audit trail after all is done
ppdata = xtp_auditTrail(ppdata, funcname, version, clock, struct('filename', inputname(1)));
