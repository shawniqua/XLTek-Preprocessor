%
% Change log:
% Ver   Date        Name            Changes
%     10/17/08      S. Williams     Created.


function xtp_consolidateXLTfiles
[filenames, pathname, filterindex] = uigetfile('*.txt', 'Please select a list of files to consolidate.');

if isstr(filenames)
    filenames = cellstr(filenames);
end

%open file for writing
fout = fopen([pathname 'out.txt'], 'a');

for f=1:length(filenames)
    [fid,message] = fopen(filename{f}, 'rt');
    if fid == -1
        disp(message)
    else
        for line=1:15
            fgetl(fid);
        end
    filedata = textscan(fid, readstring, 'TreatAsEmpty',ignorestrings,'CollectOutput', 1);
    % convert all data to numbers, weeding out the strings (like AMPSAT &
    % SHORT)
    %filedata.data{3} = str2double(filedata.data{3});
    
    % confirm that we made it to the end of the file
    if feof(fid)
        message = 'File read complete.';
        disp(message);
    else
        stopspot = ftell(fid);
        message = ['WARNING: Unable to read all data from this file. Stopped at ' num2str(stopspot)];
        disp(message);
        xtp_checkEOF(filename, stopspot);
    end
    
    fclose(fid);
end

