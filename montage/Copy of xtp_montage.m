% xtp_montage.m
% 
% This function, given a data structure containing one or more snippets of
% eeg data, produces a montaged version of that data using the headbox
% montage provided. 
%
% Example: montagedData = xtp_montage(snippets, HBmontage_id);
%
% The snippets data structure contains a metadata field (itself an array of 
% structures) and a data field, which is a cell array of data. Each element
% of the cell array is a TxL matrix of electrode voltages, where T
% represents time (number of samples) and L is the number of electrode
% leads. The matrices may or may not have the same length.
%
% hbm_id is a pointer to the index of the montage to be used from
% XTP_HB_MONTAGES, a global variable that must be set before this function
% is run. Use xtp_build_environment to create a list of possible
% hbmontages.
%

% Change control:
% VER   DATE        PERSON          CHANGE
% 1.0   10/18/08    S. Williams     Created.
% 1.1   10/19/08    S. Williams     reversed sign on montage calculation,
%                                   added dynamic(instead of manual)
%                                   copying of metadata field names
% 1.2   10/24/08    S. Williams     Added real time designation of montage.
%                                   Also declare metadata only once instead
%                                   of once for every snippet.
% 1.3   10/25/08    S. Williams     Ignore NaNs by setting them to zero
%                                   unless they actually are being used in
%                                   the montage. pass warning back if
%                                   warranted.

function [montagedData status] = xtp_montage(snippets, hbm_id)

global XTP_HB_MONTAGES

if ~(iscell(snippets.data) && isnumeric(snippets.data{1,1}))
    message = 'ERROR: snippets.data is not in the appropriate format. Please consider running xtp_cutSnippets to format correctly (as well as cut any snippets you need).';
    disp(message);
    return;
end

% This section added in v1.2
if nargin < 2
    fprintf(1, '\nWhich headbox and montage would you like to use?\n');
    for m = 1:length(XTP_HB_MONTAGES)
        fprintf(1, '  Enter %d for %s.\n', m, XTP_HB_MONTAGES(m).name);
    end
    hbm_id = input('\nYour choice> ');
end

montagedData.metadata = struct;
metadatafields = fieldnames(snippets.metadata);
[numfields junkdata] = size(metadatafields);

% end addition to v1.2

[junkvar numsnippets] = size(snippets.data);

for snippetnum = 1:numsnippets
    [numsamples numleads] = size(snippets.data{snippetnum});
    HBmontage = XTP_HB_MONTAGES(hbm_id).coefficients;
    [montagechannels montageleads] = size(HBmontage);
    if montageleads > numleads
        message = ['WARNING: There are more leads listed in this hbmontage (' num2str(montageleads) ') than in snippet ' num2str(snippetnum) ' (' num2str(numleads) '). Truncating montage definition for this snippet...'];
        disp(message);
        HBmontage = HBmontage(:,1:numleads);
        montageleads = numleads;
    end
    if numleads > montageleads
        message = ['WARNING: HBmontage ' num2str(hbm_id) ' does not specify electrode voltage coefficients for all of the leads in snippet ' num2str(snippetnum) '. (' num2str(montageleads) ' leads in the montage, ' num2str(numleads) ' in the snippet). Montaging data with a truncated snippet...'];
        disp(message);
        snippets.data = snippets.data(:,1:montageleads);
        numleads = montageleads;
    end
    %declare montagedData and copy metadata fields from snippets.metadata (v1.1)
    for field = 1:numfields
        fieldval = snippets.metadata(snippetnum).(metadatafields{field});
        montagedData.metadata(snippetnum).(metadatafields{field}) = fieldval;
    end
    %commenting this out (v1.1) since additional fields may be created and
    %would be missed if not updated here.
    %montagedData.metadata(snippetnum).sourceFile = snippets.metadata(snippetnum).sourceFile;
    %montagedData.metadata(snippetnum).start = snippets.metadata(snippetnum).start;
    %montagedData.metadata(snippetnum).end = snippets.metadata(snippetnum).end;
    %montagedData.metadata(snippetnum).units = snippets.metadata(snippetnum).units;
    %montagedData.metadata(snippetnum).srate = snippets.metadata(snippetnum).srate;
    montagedData.metadata(snippetnum).numleads = numleads; %this value may have been updated above
    %montagedData.metadata(snippetnum).hbnum = snippets.metadata(snippetnum).hbnum; % this is the value from the text file

    %additional metadata that is relevant s/p montage
    montagedData.metadata(snippetnum).HBmontageID = hbm_id; % this is the index of the hbmontage used (from xtp_environment)
    montagedData.metadata(snippetnum).HBmontageName = XTP_HB_MONTAGES(hbm_id).name; % this is the name of the hbmontage used (from xtp_environment)
    
    % added for v 1.3
    datamtx = snippets.data{snippetnum}; 
    NaNleads = sum(isnan(datamtx));
    leadsused = sum(HBmontage~=0);
    problemleads = find(NaNleads & leadsused);
    if problemleads     % if none of the NaN values in the snippet data are used in the montage
        fprintf(1,'WARNING: encountered unknown values in the following electrodes used by this montage.\n');
        fprintf(1,'%s\n',mat2str(problemleads));
        status = 2;                                                %return warning status back to calling function           
    end
    datamtx(isnan(datamtx)) = 0;                                      % set all NaNs equal to zero & proceed.
    montagedData.data{snippetnum} = datamtx*HBmontage';

end
end