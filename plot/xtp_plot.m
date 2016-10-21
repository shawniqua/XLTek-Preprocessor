% xtp_plot.m
%
% This is a crude plotting function that will allow the user to visually 
% review the output of the various other functions. It takes as input a
% data structure such as is output from xtp_montage, xtp_prefilter or
% xtp_filter.
%
% It will only plot one snippet at a time so you must tell it which one you
% want to plot.
%
%EXAMPLE: xtp_plot(snippet, snippetnum)
%

% Change log:
% ver Date      Person          Change
% 1.0 10/18/08  S.Williams      created
% 1.1 10/19/08                  plot variable number of channels per figure
%                               and standardize y dimensions

function xtp_plot(snippet, s)

global XTP_HB_MONTAGES

[numsamples numchannels] = size(snippet.data{s});

fprintf(1,'There are %d channels to plot.\n', numchannels);
subplotlen = input('How many would you like to see per window? ');
starttime = snippet.metadata(s).start;
endtime = snippet.metadata(s).end;
dateformatstr = 'mm/dd/yyyy HH:MM:SS';
startT = datenum(starttime, dateformatstr);

srate = snippet.metadata(s).srate;
t = 1/srate:1/srate:(numsamples/srate);
%t= startT:1/(srate*3600*24):startT+((numsamples-1)/(srate*3600*24));
fprintf(1, 'Plotting from  %s for %g seconds.\n', starttime, numsamples/srate);
hbm = snippet.metadata(s).HBmontageID;      % this is to be used for labelling the plots
ylimits = [min(min(min(snippet.data{s})), 0) max(max(snippet.data{s}))];
    
for w = 1:ceil(numchannels/subplotlen)
    titlestr = [snippet.metadata(s).start ' - ' snippet.metadata(s).end ' (' snippet.metadata(s).units ')'];
    figure;
    for c=1+(subplotlen*(w-1)):subplotlen*w
        if c <= numchannels
            subplot (subplotlen, 1, c-(subplotlen*(w-1)));
            plot(t,snippet.data{s}(:,c));
            grid minor;
            xlim([t(1) t(numsamples)]);
            %datetick('x', 13, 'keeplimits', 'keepticks');
            ylim(ylimits);
            ylabel(XTP_HB_MONTAGES(hbm).channelNames{c});
            % set(gca,'xtick',[]); %remove tick marks from x axis to allow more space      
        end
    end
%xlim([1 numsamples/snippet.metadata(s).srate]);
%datetick(x,13);
%set(gca,'xtickMode','auto');    %replace tick marks for the bottom  plot only
    xlabel('seconds');
    subplot(subplotlen,1,1);
    title(titlestr);
end
end
    
