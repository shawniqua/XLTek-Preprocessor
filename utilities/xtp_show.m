function xtp_show(data)
% lists environment variable data
%
% EXAMPLE: xtp_show(XTP_HB_MONTAGES) or xtp_show(XTP_HB_MONTAGES(1))
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% 1.0   04/15/09    S. Williams     Created
% 1.1   04/21/09    S. Williams     support coherency with renegade cohpairs list

global XTP_HB_MONTAGES

switch inputname(1)
    case {'XTP_HEADBOXES', 'XTP_HB_MONTAGES', 'XTP_COHERENCY_PAIRS'}
        for i=1:length(data)
            fprintf(1, '%d: %s\n',i,data(i).name)
        end
    otherwise
        if isfield(data, 'pairs')   % it's a cohPairList
            hbmid = data.HBmontageID;
            for i=1:length(data.pairs)
                fprintf(1,'%d: %s and %s\n', i, XTP_HB_MONTAGES(hbmid).channelNames{data.pairs(i,1)},XTP_HB_MONTAGES(hbmid).channelNames{data.pairs(i,2)});
            end
        elseif isfield(data, 'datatype') && strcmpi(data.datatype, 'COHERENCY')
            for i=1:length(data.cohpairs)
                fprintf(1,'%d: %s and %s\n', i, data.channelNames{data.cohpairs(i,1)},data.channelNames{data.cohpairs(i,2)});
            end 
        elseif isfield(data, 'channelNames')    %it's a montage
            for i=1:length(data.channelNames)
                fprintf(1,'%d: %s\n', i, data.channelNames{i});
            end 
        elseif isfield(data, 'lead_list')   % it's a headbox
            for i=1:length(data.lead_list)
                fprintf(1,'%d: %s\n', i, data.lead_list{i});
            end 
        end 
end %switch
end %function 