function xtp_plotSpectra(spectra1, spectra2, dsnum1, newwindow)      %plots output from xtp_mtspectrumc or xtp_coherencyc
% 
% Takes two xtp spectral structures (as output from xtp_mtspectrumc) and plots the outputs in a single figure.
% assumes individual datasets represent montage channels. Note this
% function assumes error bars have been generated (jackknife or
% theoretical)
%
%EXAMPLE: xtp_plotSpectra(spectra1, spectra2, [channel#], [newwindow]);
%

%CHANGE LOG:
% Ver   Date     Person         Change
% 1.0            S. Williams    Created
% 2.0   10/27/08 S. Williams    Revamped to take 2 spectra and optionally
%                               not open a new window
% 2.1   11/10/08 S. Williams    plot errorbars as differences from mean 
%                               instead of as absolute values
% 2.2   11/11/08 S. Williams    plot patches instead of error bar lines
% 2.3   11/11/08 S. Williams    reverted to plot errorbars as absolute
%                               values, as they are output from chronux
% 2.4   11/12/08                plot errorbar regions only if trialave=1
% 2.5   11/25/08 S. Williams    removed 'FaceColor' from call to patch2
%                               (line 90) - allows direct call within for
%                               loop from command line
% 2.6	01/14/09 S. Williams	changed to plot the following output fields:
%               				f, data, err (instead of freqs, powers, err).
%               				If the data are coherency spectra, get data  
%               				values from output.C field. if the data are 
%                   			power spectra, get data values from output.S
%                           	field. If data are old power spectra (that 
%                           	do not have a datatype), get f from freqs 
%                           	field and get data from output.powers field.
%                           	get source information from info.source field.
% 2.61  01/16/09 S.Williams     fixed call to isfield, added grandfather 
%                               clause for cparams
% 2.62  01/17/09 S.Williams     read error bars for coherence datatype as 
%                               symmetrical distance from the coherence
%                               value. Base title on XTP_COHERENCY_PAIRS
%                               and XTP_HEADBOXES.
% 2.63 01/19/09 S. Williams     for spectra, plot in dB
% 2.64 01/21/09 S. Williams     manually calculate dB, relabel power, set
%                               YLim
% 2.7   01/25/09 S. Williams    updated to read Cerr instead of err for
%                               coherency with jackknife errorbars. Also
%                               read error bars as the actual confidence
%                               limit, not the difference from estimate to
%                               confidence limit, nd do not try to plot
%                               errorbars for coherency if err !=2
% 2.8   02/07/09 S. Williams    plot log power & log error bars
% stw   02/11/09                specific changes for poster, does not
% include changes from v2.9


global XTP_HEADBOXES XTP_HB_MONTAGES XTP_COHERENCY_PAIRS

if nargin < 3
    numds1 = size(spectra1.output,2);
    numds2 = size(spectra2.output,2);
    if numds1 > 1
        fprintf(1, 'There are multiple datasets (channels) in %s.\nPlease choose one (1 to %d)\n', inputname(1), numds1);
        dsnum1 = input(': ');
    else
        dsnum1 = 1;
    end

    if numds2 > 1
        fprintf(1, 'There are multiple datasets (channels) in %s.\nPlease choose one (1 to %d \n or RETURN for same as above)', inputname(2), numds2);
        dsnum2 = input(': ');
        if isempty(dsnum2)
            dsnum2 = dsnum1;
        end
    else
        dsnum2 = 1;
    end
else
    dsnum2 = dsnum1;
end

if nargin < 4
    newwindow = input('Plot in a  new window? [Y/N] ', 's');
end
if strcmpi(newwindow, 'Y')
    figure;
end
plotErrorbars = [1 1];

% added in v2.6
if isfield(spectra1,'info') && isfield(spectra1.info, 'datatype')
    switch spectra1.info.datatype
	case 'COHERENCY'
	    spectra1.output{dsnum1}.data = spectra1.output{dsnum1}.C;
        if spectra1.info.cparams.err(1) == 2;
            spectra1.output{dsnum1}.err = spectra1.output{dsnum1}.Cerr;
        else
            plotErrorbars(1) = 0;
        end
        cplid1 = spectra1.info.cohPairListID;
        cohPair1 = XTP_COHERENCY_PAIRS(cplid1).pairs(dsnum1,1:2);
        hbid1 = XTP_COHERENCY_PAIRS(cplid1).headbox_id;
        location1 = [XTP_HEADBOXES(hbid1).lead_list{cohPair1(1)} '-' XTP_HEADBOXES(hbid1).lead_list{cohPair1(2)}];
        ylab = 'coherence';
        ylimits = [0 1];
	case 'POWER SPECTRA'
	    spectra1.output{dsnum1}.data = 10*log10(spectra1.output{dsnum1}.S);
	    spectra1.output{dsnum1}.err = 10*log10(spectra1.output{dsnum1}.err);
        hbmid1 = spectra1.metadata(1).HBmontageID;  %hardcoded assumption that all datasets in a given structure use the same montage
        location1 = XTP_HB_MONTAGES(hbmid1).channelNames{dsnum1};
        ylab = 'Power (dB)';
        ylimits = [-25 25];
    end
else 	% if spectra were run wo any designation of datatype (i.e. before 1/15)
    spectra1.info.source = spectra1.source;   
    spectra1.info.cparams = spectra1.cparams;   
    spectra1.output{dsnum1}.f = spectra1.output{dsnum1}.freqs;   
    spectra1.output{dsnum1}.data = log10(spectra1.output{dsnum1}.powers);   
    spectra1.output{dsnum1}.err = log10(spectra1.output{dsnum1}.err);   
    hbmid1 = spectra1.metadata(1).HBmontageID;  %hardcoded assumption that all datasets in a given structure use the same montage
    location1 = XTP_HB_MONTAGES(hbmid1).channelNames{dsnum1};
    ylab = 'log power (mV^2/Hz^2)';
    ylimits = [-10 -4];
end

if isfield(spectra2,'info') && isfield(spectra2.info, 'datatype')
    switch spectra2.info.datatype
	case 'COHERENCY'
	    spectra2.output{dsnum1}.data = spectra2.output{dsnum1}.C;
        if spectra2.info.cparams.err(1) == 2;
            spectra2.output{dsnum1}.err = spectra2.output{dsnum1}.Cerr;
        else
            plotErrorbars(2) = 0;
        end
        cplid2 = spectra2.info.cohPairListID;
        cohPair2 = XTP_COHERENCY_PAIRS(cplid2).pairs(dsnum1,1:2);
        hbid2 = XTP_COHERENCY_PAIRS(cplid2).headbox_id;
        location2 = [XTP_HEADBOXES(hbid2).lead_list{cohPair2(1)} '-' XTP_HEADBOXES(hbid2).lead_list{cohPair2(2)}];
        ylab = 'coherence';
        ylimits = [0 1];
	case 'POWER SPECTRA'
	    spectra2.output{dsnum1}.data = 10*log10(spectra2.output{dsnum1}.S);
	    spectra2.output{dsnum1}.err = 10*log10(spectra2.output{dsnum1}.err);
        hbmid2 = spectra2.metadata(1).HBmontageID;
        location2 = XTP_HB_MONTAGES(hbmid2).channelNames{dsnum2};
        ylab = 'Power (dB)';
        %ylimits = [-10 -4];
    end
else 	%grandfather clauses for spectra that have been run without any designation of datatype
    spectra2.info.source = spectra2.source;   
    spectra2.info.cparams = spectra2.cparams;   
    spectra2.output{dsnum1}.f = spectra2.output{dsnum1}.freqs;  
    spectra2.output{dsnum1}.data = log10(spectra2.output{dsnum1}.powers); 
    spectra2.output{dsnum1}.err = log10(spectra2.output{dsnum1}.err); 
    hbmid2 = spectra2.metadata(1).HBmontageID;
    location2 = XTP_HB_MONTAGES(hbmid2).channelNames{dsnum2};
    ylab = 'log power(mV^2/Hz^2)';
    ylimits = [-10 -4];
end
% end of v2.6 addition

if plotErrorbars(1)
    lowerlim1 = spectra1.output{dsnum1}.err(1,:)';
    upperlim1 = spectra1.output{dsnum1}.err(2,:)';
    patchX1 = [spectra1.output{dsnum1}.f xtp_mirror(spectra1.output{dsnum1}.f)];
    patchY1 = [lowerlim1; xtp_mirror(upperlim1)];
    patch1 = patch(patchX1,patchY1,[255 80 80]/255,'FaceAlpha', 0.25, 'EdgeColor','none');
end

lh1 = line(spectra1.output{dsnum1}.f, spectra1.output{dsnum1}.data,'Color', [204 0 0]/255, 'Tag', inputname(1));

set(gca,'FontSize',14);
if spectra1.info.cparams.trialave == 1
    set(lh1, 'LineWidth', 1.5);
    
end

if plotErrorbars(2)
    lowerlim2 = spectra2.output{dsnum2}.err(1,:)';
    upperlim2 = spectra2.output{dsnum2}.err(2,:)';
    patchX2 = [spectra2.output{dsnum2}.f xtp_mirror(spectra2.output{dsnum2}.f)];
    patchY2 = [lowerlim2; xtp_mirror(upperlim2)];
    patch2 = patch(patchX2,patchY2,[51 153 255]/255,'FaceAlpha', 0.25, 'EdgeColor','none');
end

lh2 = line(spectra2.output{dsnum2}.f, spectra2.output{dsnum2}.data, 'Color', [0 102 204]/255, 'Tag',inputname(2));
if spectra2.info.cparams.trialave == 1
    set(lh2, 'LineWidth',1.5);
end

lh3 = line([10 10],[-25 25],'Color','k','LineStyle', ':');

legend([lh1(1) lh2(1)], 'Hour Before Dose', 'Hour After Dose');
legend('boxoff')
%legend('Location','Best')

minx = min(spectra1.info.cparams.fpass, spectra2.info.cparams.fpass);
maxx = max(spectra1.info.cparams.fpass, spectra2.info.cparams.fpass);
xlim([minx(1) maxx(2)]);
xlim([0 50]);
%ylim([10^-9 10^-4]);
ylim(ylimits);
xlabel('Frequency (Hz)');
ylabel(ylab);          


titlestr = [spectra1.info.source '(' location1 ') vs. ' spectra2.info.source '(' location2 ')'];
title(['Day 5, Dose 1 (' location1 ')']);

end         

    
