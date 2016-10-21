function spectra = xtp_mtspectrumc(preProcessedData, cparams)   
% calls mtspectrumc for data exported from XLTek using XTP
%
% This function crudely takes in a dataset that has been processed by the
% XLTek Preprocessor (functions named xtp_*) and runs the chronux command
% mtspectrumc on it. Unless otherwise noted, the parameters passed to 
% chronux are those listed in the global parameter XTP_CHRONUX_PARAMS. Trials of
% different lengths (different numbers of samples) are padded to the length of the 
% longest trial. All trials are then padded according to the params.pad field.
%
% Output is a structure with the following fields:
%   spectra.info        metadata related to this run
%   spectra.metadata    structure array copied from the source data structure.
%                       each cell contains the metadata from the 
%                       corresponding trial 
%   spectra.output      a structure array of C elements (one for each channel)
%                       each containing 2 or 3 fields:
%                           .f      -frequencies output by mtspectrumc (length F)
%                           .err    -2xF matrix of errorbars, lower limits in
%                                    row 1 and upper limits in row 2
%                           .S	    -spectral power, in a FxT matrix (F = number 
%                                    of frequencies, T = number of trials. 
%                                    T=1 if trialave=1)
% 
% EXAMPLE: spectra = xtp_mtspectrumc(preProcessedData, chronuxParams);
%
% all trials must have the same number of channels.
%

% Change log:
% ver   Date      Person          Change
% 1.0   10/19/08  S. Williams   Created
% 1.1   10/20/08  S. Williams   reversed order of dimensions in datacube
% 1.2   10/21/08  S. Williams   tracking source of data from preprocessed
%                               data structure. re-reversed dimensions to
%                               show samples in rows and channels or trials
%                               in columns or 3rd dim. revised storage of
%                               error bars in output
% 1.3   10/24/08 S. Williams    standardized datacube dimensions to SxTxC
%                               regardless of choice for trial averaging
% 1.31  10/27/08                updated helptext
% 1.4   01/14/09 S. Williams	added info field to help identify how
%                               the data was created. moved source & cparams 
%                   			into info field structure. changed output.freqs
%               				field to output.f and output.powers to 
%                               output.S for consistency with chronux user 
%               				manual. remove datacube. use cparams instead 
%                               of cParams.
% 1.41 01/23/09 S. Williams     fixed call to rmfield, brought it above
%                               function end. added separate info field for
%                               function version.
% 1.5  06/25/09 S. Williams     made datacube its own separate variable
%                               (instead of a field on spectra variable.
%                               this may improve speed. Also remoed padding
%                               of timeseries as this leads to potentially bad
%                               power spectral estimates. Instead default
%                               behavior is to warn user and cut off all
%                               segments at a max length equal to the
%                               length of the shortest segment. Add status
%                               messages for user perspective.
% 1.6   11/16/09 S. Williams    list channelNames in .info
% 1.7   06/20/10 S. Williams    allow number of channelNames ~= number of
%                               channels in data (for EMU40)
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_mtspectrumc.m';
version = 'v1.7';

%% getting started...
global XTP_CHRONUX_PARAMS

if nargin < 2
    cparams = XTP_CHRONUX_PARAMS;
end

numtrials = size(preProcessedData.data,2);
% if isfield(preProcessedData, 'info')
%     numchannels = size(preProcessedData.info.channelNames,1);
% else
    numchannels = size(preProcessedData.data{1},2);     % messier alternative
% end
% v1.7: removed this if-statement to support the case where channelNames is
% longer than the number of channels in the data (EMU40). 

%% check the maximum number of samples of any trial, and pad the shorter trials (removed in v1.5)
% maxsamples = 0;
% for trial = 1:numtrials         % wouldn't need this loop if I stored #samples in metadata!
%     [numsamples numchannels] = size(preProcessedData.data{trial});
%     maxsamples = max(maxsamples, numsamples);
% end
% for trial = 1:numtrials
%     [numsamples numchannels] = size(preProcessedData.data{trial});
%     if numsamples < maxsamples
%         padlen = maxsamples - numsamples;
%         fprintf(1, 'Padding trial number %d symmetrically with %d additional samples.\n', trial, padlen);            
%         preProcessedData.data{trial} = padarray(preProcessedData.data{trial}, [padlen 0], 'symmetric', 'post');
%     end
% end
[numsamples(1:numtrials)] = preProcessedData.metadata.numsamples;
maxsamples = min(numsamples);       % epochs must be of the same length to be compared. limit the length of data used to the length of the shortest epoch.
if find(numsamples>maxsamples)
    fprintf(1,'WARNING: epochs are of different lengths. Using only the first %d samples of each epoch for the spectral estimates.\n',maxsamples);
end

%% once trials are padded, they can be combined into a single 3D matrix.
% (Also convert the metadata for each trial.)

% spectra.srate = preProcessedData.metadata(trial).srate;                 % shameless hack. 
% spectra.HBmontageID = preProcessedData.metadata(trial).HBmontageID;     % shameless hack. 

% removed this section in v1.3
%if numtrials>1 && cParams.trialave      % datamatrix is SxTxC
%    %spectra.dataDimensions = 'trials x samples x channels';        %removed in v1.2
%    spectra.dataDimensions = 'samples x trials x channels';         %added in v1.2
%    for c = 1:numchannels
%        for trial=1:numtrials
%            %spectra.datacube(trial,:,c) = preProcessedData.data{trial}(:,c);    %removed in v1.2
%            spectra.datacube(:,trial,c) = preProcessedData.data{trial}(:,c);     %added in v1.2
%        end
%        spectra.source{c} = ['Channel' num2str(c) ': ' XTP_HB_MONTAGES(spectra.HBmontageID).channelNames{c}];
%    end
%else                                    % else the datamatrix is SxCxT

%datamatrix will always be SxCxT
%spectra.dataDimensions = 'channels x samples x trials';         %removed in v1.2
%    spectra.dataDimensions = 'samples x channels x trials';         %added in v1.2, removed in v1.3

spectra.info.datatype = 'POWER SPECTRA';
spectra.info.source = inputname(1);
spectra.info.generatedBy = funcname;
spectra.info.version = version;
spectra.info.rundate = clock;
spectra.info.cparams = cparams;
if isfield(preProcessedData.info, 'channelNames')
    spectra.info.channelNames = preProcessedData.info.channelNames;
end

spectra.metadata = struct;
metadatafields = fieldnames(preProcessedData.metadata);
numfields = size(metadatafields,1);
datacube = NaN(maxsamples,numtrials,numchannels);
for trial = 1:numtrials
    for field = 1:numfields
        fieldval = preProcessedData.metadata(trial).(metadatafields{field});
        spectra.metadata(trial).(metadatafields{field}) = fieldval;
    end
    datacube(:,trial,:) = preProcessedData.data{trial}(1:maxsamples,:);     % size = (maxsamples x numtrials x numchannels)
end

%% call mtspectrumc

%[samples trials channels] = size(datacube);    %should not be necessary in v1.5
fprintf(1,'calculating spectra for channel: ');
for c = 1:numchannels
    fprintf(1,'%d...',c);
    if cparams.err == 0
        [S f] = mtspectrumc(datacube(:,:,c), cparams);
    else
        [S f Serr] = mtspectrumc(datacube(:,:,c), cparams);
        spectra.output{c}.err = Serr;
    end
    spectra.output{c}.f = f;
    spectra.output{c}.S = S;
end
fprintf(1,'\nDone.\n');
% spectra = rmfield(spectra, 'datacube'); % removed in v1.5

end

