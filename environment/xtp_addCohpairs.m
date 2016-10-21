function xtp_addCohpairs(cohPairList, cplname, hbmid)
% This function allows you to interactively select leads to analyze for
% coherency and coherogram estimates.
%
% EXAMPLE: xtp_addCohpairs([cohPairList], [name], [HBmontageID])
%
% CHANGE CONTROL
% VER   DATE        PERSON          CHANGE
% ----- ----------- --------------- ---------------------------------------
% 1.0   03/19/09    S. Williams     Created
% 1.1   04/09/09    S. Williams     allow user to specify the cohpairlist
%                                   in command line. 
% 1.2   04/10/09    S. Williams     add reference to HBmontageID, list
%                                   leads based on XTP_HB_MONTAGES instead
%                                   of XTP_HEADBOXES.

global XTP_COHERENCY_PAIRS XTP_HB_MONTAGES

if nargin < 3    %no hbmid identified
    fprintf(1,'Please choose a montage from the following list:\n');
    for hbmid = 1:length(XTP_HB_MONTAGES)
        fprintf(1,'%d: %s\n', hbmid, XTP_HB_MONTAGES(hbmid).name);
    end
    hbmid = input('Your choice> ');

    if nargin < 2   %no hbmid nor CPL name
        fprintf(1,'Please enter a name for your coherency pair list:\n');
        cplname = input('Your choice> ','s');
    end
end
XTP_COHERENCY_PAIRS(end+1).name = cplname;
XTP_COHERENCY_PAIRS(end).headbox_id = XTP_HB_MONTAGES(hbmid).headbox_id;
XTP_COHERENCY_PAIRS(end).HBmontageID = hbmid;

if nargin < 1   %no CPL identified
    addpair = 1;
    XTP_COHERENCY_PAIRS(end).pairs = [];
    while addpair
        fprintf(1, 'Here is a list of the channels for montage \n%s: \n', XTP_HB_MONTAGES(hbmid).name);
        for lead = 1:size(XTP_HB_MONTAGES(hbmid).channelNames,1)
            fprintf(1,'%d: %s\n', lead, XTP_HB_MONTAGES(hbmid).channelNames{lead});
        end
        newpair = input('Please select 2 channels for the next pair (format [a b]):');
        XTP_COHERENCY_PAIRS(end).pairs = cat(1, XTP_COHERENCY_PAIRS(end).pairs, newpair);
        fprintf(1,'Channels %s and %s added for coherence calculation.\n', XTP_HB_MONTAGES(hbmid).channelNames{newpair(1)}, XTP_HB_MONTAGES(hbmid).channelNames{newpair(2)});
        addpair = input('Add another pair? [1=Yes, 0=No]');
    end %while
else
    XTP_COHERENCY_PAIRS(end).pairs = cohPairList;
end 

fprintf(1,'The following new list has been created:\n');
fprintf(1,'XTP_COHERENCY_PAIRS(%d):\n', length(XTP_COHERENCY_PAIRS));
fprintf(1,'name: %s\n', XTP_COHERENCY_PAIRS(end).name);
fprintf(1,'headbox: %s\n', XTP_HB_MONTAGES(XTP_COHERENCY_PAIRS(end).HBmontageID).name);
fprintf(1,'pair:\t%s %s \n', XTP_HB_MONTAGES(XTP_COHERENCY_PAIRS(end).HBmontageID).channelNames{permute(XTP_COHERENCY_PAIRS(end).pairs,[2 1])});


end
