function xtp_plotCohgram(cohgram, PPCdata, cohpairs)
% plots cohgram as output from xtp_cohgramc.
% copied from parse_spec_demo
%
% EXAMPLE: xtp_plotCohgram(cohgram, PPCdata, [cohpairs])
%           where cohpairs is an array indicating the channel pairs to plot
%
% CHANGE CONTROL:
% ver   date        person          change
% ----- ----------- --------------- ---------------------------------------
% 1.0   03/13/09    S. Williams     Copied from parse_spec_demo with
%                                   updates for data structure
% 1.1   03/18/09    S. Williams     bugfix: only print as many cohpairs as
%                                   you have. epoch delineation lines
%                                   thinner. Support vanilla labelling when 
%                                   cohpairlist is manually specified. add
%                                   colorbars
% 1.2   03/20/09    S. Williams     Take timeseries as a separate variable
%                                   instead of assuming it is part of the
%                                   cohgram. also optionally take a single
%                                   cohpair to plot instead of plotting all
%                                   of them.
% 1.3   03/26/09    S. Williams     scale width of timeseries plot to match
%                                   spectral plots. add colorbar management
%                                   from parse_spectrogram_demo
% 1.4   04/10/09    S. Williams     reference XTP_HB_MONTAGES instead of
%                                   XTP_HEADBOXES
% 1.5   05/07/09    S. Williams     allow multiple cohpairs in command line

% DEPENDENCIES: phacolor.m
if nargin < 3
    for cohpair= 1:size(cohgram.output,2)
        xtp_plotCG(cohgram, PPCdata, cohpair)
    end
else
    for cohpair=cohpairs
        xtp_plotCG(cohgram, PPCdata, cohpair)
    end
end
end
function xtp_plotCG(cohgram, PPCdata, cohpair)
    global XTP_COHERENCY_PAIRS XTP_HB_MONTAGES

    % first restructure data with epochs in succession
    lead1num = cohgram.info.cohPairList(cohpair,1);
    lead2num = cohgram.info.cohPairList(cohpair,2);
    numepochs = size(cohgram.output,1);
    totalsamples = 0;
    TSmarkers = [];
    totalwindows = 0;
    WINmarkers = []; 
    for epochnum=1:numepochs
        TSmarkers = [TSmarkers totalsamples+1];    % marks the index of the first time sample of each epoch
        epochsamples = size(PPCdata.data{epochnum},1);
        timeseries(totalsamples+1:totalsamples+epochsamples,:) = PPCdata.data{epochnum}(:,[lead1num lead2num]);

        WINmarkers = [WINmarkers totalwindows+1];   % marks the index of the first window of each spectrum
        epochwindows = length(cohgram.output{epochnum,cohpair}.t);
        C(totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.C;
        phi(totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.phi;        
        S12(totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.S12;
        S1(totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.S1;
        S2(totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.S2;
        t(totalwindows+1:totalwindows+epochwindows) = cohgram.output{epochnum,cohpair}.t;
        if isfield(cohgram.output{epochnum,cohpair},'confC')     % so err >= 1
            confC(totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.confC;
            phistd(totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.phistd;
            if isfield(cohgram.output{epochnum,cohpair},'Cerr')     % so err = 2
                Cerr(:,totalwindows+1:totalwindows+epochwindows,:) = cohgram.output{epochnum,cohpair}.Cerr;
            end
        end
        totalsamples = totalsamples+epochsamples;
        totalwindows = totalwindows+epochwindows;
    end
    f = cohgram.output{1}.f;
    min_pwr = 10^-9;
%     S1range=[floor(max(min(10*log10(S1(:))),min_pwr)) ceil(max(10*log10(S1(:))))]; % min & max for S1 & S2 across all channels (NOT channel pairs)?
%     S2range=[floor(max(min(10*log10(S2(:))),min_pwr)) ceil(max(10*log10(S2(:))))]; 
%     S12range=[floor(max(min(10*log10(S12(:))),min_pwr)) ceil(max(10*log10(S12(:))))];
    S1range=[floor(min(10*log10(S1(:)))) ceil(max(10*log10(S1(:))))]; % min & max for S1 & S2 across all channels (NOT channel pairs)?
    S2range=[floor(min(10*log10(S2(:)))) ceil(max(10*log10(S2(:))))]; 
%     S12range=[floor(min(10*log10(S12(:)))) ceil(max(10*log10(S12(:))))];
    SGrange = [min([S1range(1) S2range(1)]) max([S1range(2) S2range(2)])];

    % prep for plotting
    figure;
    nrows = 3;
    ncols = 2;
    xlimits = [0-0.5 totalsamples+0.5];
    XLab = ['samples (' num2str(PPCdata.metadata(1).srate) '/sec)'];

    % plot coherence phase first - address colormap issue
    subplot(nrows,ncols,6)
    im6 = imagesc([1:totalsamples]',f,phi'/(2*pi),[-0.5 0.5]);
    hold
    for epochnum=1:numepochs
        plot([TSmarkers(epochnum) TSmarkers(epochnum)]-0.5, ylim, 'Color', 'k', 'LineWidth', 1);
    end
    set(gca,'YDir','normal', 'FontSize', 8)
    title('Coherence Phase')
    ylabel('frequency (Hz)')
    xlim(xlimits)
    xlabel(XLab)
    colormap(phacolor(size(colormap,1))); %set up color map for phase
    colorbar


    % plot timeseries
    hrawax=subplot(nrows,ncols,1);
    li=plot([1:totalsamples]', timeseries); hold on
%     miny = min(min(timeseries));
%     maxy = max(max(timeseries));
    for epochnum=1:numepochs
        plot([TSmarkers(epochnum) TSmarkers(epochnum)], ylim, 'Color', 'k');
    end
    if cohgram.info.cohPairListID
        lead1name = XTP_HB_MONTAGES(XTP_COHERENCY_PAIRS(cohgram.info.cohPairListID).HBmontageID).channelNames{lead1num};
        lead2name = XTP_HB_MONTAGES(XTP_COHERENCY_PAIRS(cohgram.info.cohPairListID).HBmontageID).channelNames{lead2num};
    else
        if isfield(cohgram.info, 'channelNames')
            lead1name = cohgram.info.channelNames{lead1num};
            lead2name = cohgram.info.channelNames{lead2num};            
        else
            lead1name = ['Lead ' num2str(lead1num)];
            lead2name = ['Lead ' num2str(lead2num)];
        end
    end
    le=legend(li,lead1name,lead2name, 'Location', 'EastOutside');
    tstring = [lead1name ' - ' lead2name];
    set(gcf,'Name',tstring);
    set(gcf,'NumberTitle','off');
    set(gca, 'FontSize', 8)
    title(['timeseries (' PPCdata.metadata(1).units ')'])
    ylabel(PPCdata.metadata(1).units)
    xlabel(XLab)
    xlim(xlimits)


    % plot spectra
    s1ax = subplot(nrows,ncols,3);
    im3 = imagesc([1:totalsamples]',f,10*log10(S1'), SGrange);
    hold
    for epochnum=1:numepochs
        plot([TSmarkers(epochnum) TSmarkers(epochnum)]-0.5, ylim, 'Color', 'k', 'LineWidth', 1);
    end
    set(gca,'YDir','normal', 'FontSize', 8)
    xlim(xlimits)
    xlabel(XLab)
    title([lead1name ' Spectrum (dB)'])
    ylabel('frequency (Hz)')
    set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
    hc=colorbar;set(hc,'YLim',get(hc,'YLim')*[1 0.1;0 0.9]);
    
    % go back and resize timeseries axis to match spectral plot with colorbar
    s1pos = get(s1ax, 'Position');
    tspos = get(hrawax, 'Position');
    set(hrawax, 'Position', sum([s1pos.*[0 0 1 0];tspos.*[1 1 0 1]]))
    
    % continue plotting spectra
    s2ax = subplot(nrows,ncols,5);
    im5 = imagesc([1:totalsamples]',f,10*log10(S2'), SGrange);
    hold
    for epochnum=1:numepochs
        plot([TSmarkers(epochnum) TSmarkers(epochnum)]-0.5, ylim, 'Color', 'k', 'LineWidth', 1);
    end
    set(gca,'YDir','normal', 'FontSize', 8)
    title([lead2name ' Spectrum (dB)'])
    ylabel('frequency (Hz)')
    xlim(xlimits)
    xlabel(XLab)
    set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
    hc=colorbar;set(hc,'YLim',get(hc,'YLim')*[1 0.1;0 0.9]);

    subplot(nrows,ncols,2)
    im2 = imagesc([1:totalsamples]',f,10*log10(abs(S12')), SGrange);
    hold
    for epochnum=1:numepochs
        plot([TSmarkers(epochnum) TSmarkers(epochnum)]-0.5, ylim, 'Color', 'k', 'LineWidth', 1);
    end
    set(gca,'YDir','normal', 'FontSize', 8)
    title('Cross-Spectrum (dB)')
    ylabel('frequency (Hz)')
    xlim(xlimits)
    xlabel(XLab)
    set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
    hc=colorbar;set(hc,'YLim',get(hc,'YLim')*[1 0.1;0 0.9]);

    subplot(nrows,ncols,4)
    im4 = imagesc([1:totalsamples]',f,C',[0 1]);
    hold
    for epochnum=1:numepochs
        plot([TSmarkers(epochnum) TSmarkers(epochnum)]-0.5, ylim, 'Color', 'k', 'LineWidth', 1);
    end
    set(gca,'YDir','normal', 'FontSize', 8)
    title('Coherence Amplitude')
    ylabel('frequency (Hz)')
    xlim(xlimits)
    xlabel(XLab)
    set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
    hc=colorbar;
    set(hc,'YLim',get(hc,'YLim')*[1 0.1;0 0.9]);
% 
% 
%     
%     xlabel('t (sec)','FontSize',font_size);
%     title(tstring,'Interpreter','none','FontSize',font_size);
% 
%     legend('ch 1','ch 2');
%     set(gca,'XLim',[tvals(plist(1))-dt,tvals(plist(end))]);
%     set(gca,'YLim',[min(data_reshaped(:)),max(data_reshaped(:))])
%     set(gca,'FontSize',font_size);
% 
%     %
%     %plot the spectrograms
%     %
%     for ic=1:nchans
%         subplot(nrows,ncols,1+ncols*ic);
%         t_start=tvals(1+(iswatch-1)*npts_swatch);
%         imagesc(t-dt+t_start,f,(log10(SG(:,:,ic,iswatch)))',SGrange);set(gca,'YDir','normal');
%         hspect=gca;
%         title(sprintf('log spectrogram, ch %1.0f',ic),'FontSize',font_size);
%         %xlabel('t (sec)','FontSize',font_size)
%         ylabel('f (Hz)','FontSize',font_size);
%         set(gca,'XLim',[tvals(plist(1))-dt,tvals(plist(end))]);
%         set(gca,'YLim',[0 max(f)]);
%         set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
%         hc=colorbar;set(hc,'YLim',get(hc,'YLim')*[1 0.1;0 0.9]);
%         set(gca,'FontSize',font_size);
%     end
%     set(hrawax,'Position',get(hrawax,'Position').*[0 1 0 1]+get(hspect,'Position').*[1 0 1 0]); %adjust x-axis fo raw traces
%     %
%     %plot cross-spectrogram
%     %
%     subplot(nrows,ncols,1+ncols*(nchans+1));
%     imagesc(t-dt+t_start,f,log10(max(abs(S12'),min_pwr)),SGrange);set(gca,'YDir','normal');
%     title('log cross-spectrogram amplitude','FontSize',font_size);
%     %xlabel('t (sec)','FontSize',font_size)
%     ylabel('f (Hz)','FontSize',font_size);
%     set(gca,'XLim',[tvals(plist(1))-dt,tvals(plist(end))]);
%     set(gca,'YLim',[0 max(f)]);
%     set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
%     hc=colorbar;set(hc,'YLim',get(hc,'YLim')*[1 0.1;0 0.9]);
%     set(gca,'FontSize',font_size);
%     %
%     %plhc=ot coherence amplitude
%     %
%     subplot(nrows,ncols,1+ncols*(nchans+2));
%     imagesc(t-dt+t_start,f,C',[0 1]);set(gca,'YDir','normal');
%     title('coherence amplitude','FontSize',font_size);
%     %xlabel('t (sec)','FontSize',font_size)
%     ylabel('f (Hz)','FontSize',font_size);
%     set(gca,'XLim',[tvals(plist(1))-dt,tvals(plist(end))]);
%     set(gca,'YLim',[0 max(f)]);
%     set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
%     hc=colorbar;set(hc,'YLim',get(hc,'YLim')*[1 0.1;0 0.9]);
%     set(gca,'FontSize',font_size);
%     %
%     %plot coherence phase
%     %
%     subplot(nrows,ncols,1+ncols*(nchans+3));
%     imagesc(t-dt+t_start,f,phi'/(2*pi),[-0.5 0.5]);set(gca,'YDir','normal');
%     %the color map messes up the others unless the ranges are compressed
%     (see phacolor.m)
%     colormap(phacolor(size(colormap,1))); %set up color map for phase
%     title('coherence phase/(2*pi)','FontSize',font_size);
%     %xlabel('t (sec)','FontSize',font_size)
%     ylabel('f (Hz)','FontSize',font_size);
%     set(gca,'XLim',[tvals(plist(1))-dt,tvals(plist(end))]);
%     set(gca,'YLim',[0 max(f)]);
%     colorbar;
%     set(gca,'FontSize',font_size);
end