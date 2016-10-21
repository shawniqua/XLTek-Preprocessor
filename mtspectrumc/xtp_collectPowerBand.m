function powerband = xtp_collectPowerBand(fband, varargin)

% This function, given a list of spectra, calculates the power band
% for each spectrum and returns it in a S x F x C matrix with 
% S = # of spectra, C = # montage channels, F = # frequency bands.
%
% fband should be an Fx2 array with ranges of frequencies for which
% to calculate the power. One row per frequency band. 
%
% EXAMPLE:
% powerBand = xtp_collectPowerBand(fband, spectrum1, spectrum2, ...)
%
% Ver 	Date 	 Person 	Change
% 1.0 	12/10/08 S. Williams 	Created.
%

global XTP_HB_MONTAGES

numspectra = size(varargin,2);
numchannels = size(varargin{1}.output, 2);
powerband.source = cell(numspectra,1);
powerband.metadata = cell(1,numspectra);
powerband.data = zeros(numspectra, size(fband,1),numchannels);

for band=1:size(fband,1)
    for s = 1:numspectra
        for c=1:numchannels
            fbandindices = [find(varargin{s}.output{c}.freqs > fband(band,1),1,'first') find(varargin{s}.output{c}.freqs <= fband(band,2),1,'last')];
            powerband.data(s,band,c) = sum(varargin{s}.output{c}.powers(fbandindices(1):fbandindices(2)));
%            powerband.data(s,c,band) = sum(varargin{s}.output{c}.powers(find(varargin{s}.output{c}.freqs <= fband(band,2))));
            powerband.metadata{s} = varargin{s}.metadata;
            powerband.source{s} = varargin{s}.source;
        end
    end
    % prep for plotting
    fbandtext{band} = [num2str(fband(band,1)) '-' num2str(fband(band,2)) 'Hz'];
end

%plot
figure;
xaxis = [-1 0 1 2 3];
for c=1:numchannels
    subplot(5,4,c)  %assumes 18 channels - need to make this more generic.
    semilogy(xaxis,powerband.data(:,:,c))
    set(gca,'FontSize',6);
    hbmid = powerband.metadata{1}(1).HBmontageID;
    hbm = XTP_HB_MONTAGES(hbmid).channelNames{c};
    title(hbm);
    set(gca,'XTick',xaxis)
    set(gca,'XTickLabel',{'Hour0';'Hour1';'Hour2';'Hour3';'Hour4'})
    xlabel('hours after dose');
    ylabel('band power');
end
subplot (5,4,c+1)
semilogy(powerband.data(:,:,c))
set(gca,'FontSize',6);
legend(fbandtext);
end
        