function [coeffMatrix, channelNames, montageID] = xtp_createMontage(varargin)
% interactively creates a bipolar montage matrix for use in XTP_MONTAGES
%
% EXAMPLE: 
% [coeffMatrix, channelNames, montageID] = xtp_createMontage(headboxID, 'Name', 'Value',...)
% 
% Where headboxID is the index of the headbox to use. Find candidate
% headboxes using xtp_show(XTP_HEADBOXES) and look at the detailed list of
% electrodes for one in particular using xtp_show(XTP_HEADBOXES(<hbid>))
%
% and name/value pairs are of:
%   'avgRef' (true or false) indicates whether to do common average reference
%       montage
%   'include' - vector of channel indices to include in average reference
%       calculation (superceded by exclude list)
%   'exclude' - vector of indices of channels to exclude from average
%       reference calculation. Superceded include list
%   'name' - string indicating the name of the montage to create in
%       XTP_HB_MONTAGES
%
% CHANGE CONTROL
% VER   DATE        PERSON      CHANGE
% ----- ----------- ----------- ------------------------------------------
% 1.0   03/27/09    S. Williams Created.
% 1.1   04/23/09    S. Williams create the montage
% 1.2   07/22/16    S. Williams added montageID as output variable. added
%                               optional input arguments to specify common
%                               average reference, electrodes to exclude
%                               and determine whether to save the
%                               new montage. Headbox ID becomes a required
%                               input argument.

global XTP_HEADBOXES XTP_HB_MONTAGES

p = inputParser;
defaultAvgRef = false;
defaultExcludeLeads = [];
addRequired(p,'headboxID');
addParameter(p,'avgRef',defaultAvgRef,@islogical);
addParameter(p,'include',nan);
addParameter(p,'exclude',defaultExcludeLeads,@isnumeric);
addParameter(p,'name','<no name specified>')
parse(p,varargin{:});

if isfield(p.Results, 'headboxID')     %% headbox was speciifed
    hbid = p.Results.headboxID;
else 
    for hbid = 1:length(XTP_HEADBOXES)
        fprintf(1,'%d: %s\n',hbid, XTP_HEADBOXES(hbid).name)
    end
    hbid = input('Please choose a headbox: ');
end
numleads = size(XTP_HEADBOXES(hbid).lead_list,1);
lead1 = [];
lead2 = [];
coeffMatrix = [];
channelNames = [];
addAnother = 1;
channel = 0;

avgRef = p.Results.avgRef;

if isnan(p.Results.include)
    includeLeads = 1:numleads;
else
    includeLeads = p.Results.include;
end

excludeLeads = p.Results.exclude;

if avgRef
    coeffMatrix = zeros(numleads);
    coeffMatrix(:,includeLeads) = -1;
    coeffMatrix(:,excludeLeads) = 0;
    coeffMatrix = coeffMatrix./(length(find(coeffMatrix(1,:))));
    coeffMatrix = coeffMatrix + diag(ones(numleads,1));
    channelNames = XTP_HEADBOXES(hbid).lead_list;
else
    while addAnother
        channel = channel+1;
        for lead=1:numleads
            fprintf(1,'%d: %s\n', lead, XTP_HEADBOXES(hbid).lead_list{lead});
        end
        fprintf(1,'Please specify the first lead of channel %d',channel);
        lead1(channel) = input(': ');
        fprintf(1,'Please specify the second lead of channel %d',channel);
        lead2(channel) = input(': ');
        coeffMatrix = [coeffMatrix;zeros(1,numleads)];
        coeffMatrix(channel,lead1(channel)) = 1;
        coeffMatrix(channel,lead2(channel)) = -1;
        channelNames{channel} = cat(2,XTP_HEADBOXES(hbid).lead_list{lead1(channel)}, '-',XTP_HEADBOXES(hbid).lead_list{lead2(channel)}); 
        fprintf(1, 'Added channel %d: %s\n',channel, channelNames{channel});
        addAnother = input('Add another channel? [0 = No, 1 = Yes, default 1]: ');
        if isempty(addAnother)
            addAnother = 1;
        end
    end
end
channelNames = channelNames';
montageID = [];

% if input('Save this montage temporarily? (1=Yes, 0=No)')
%     XTP_HB_MONTAGES(end+1).name = input('Please specify a name for the new montage (use quotes):', 's');
if isfield(p.Results, 'name')
    XTP_HB_MONTAGES(end+1).name = p.Results.name;
    XTP_HB_MONTAGES(end).headbox_id = hbid;
    XTP_HB_MONTAGES(end).channelNames = channelNames;
    XTP_HB_MONTAGES(end).coefficients = coeffMatrix;
    montageID = length(XTP_HB_MONTAGES);
    
    fprintf(1,'\nCreated montage %d in XTP_HB_MONTAGES.\nType xtp_show(XTP_HB_MONTAGES(%d)) to verify your channels.\n', length(XTP_HB_MONTAGES),length(XTP_HB_MONTAGES));
    fprintf(1,'NOTE: this montage has NOT been added to xtp_build_environment. \n It will be erased next time you build the environment or close MATLAB.\n');
    fprintf(1,'To avoid this, you must manually add the code to xtp_build_environment.\n');
end
end