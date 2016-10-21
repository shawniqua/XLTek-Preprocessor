function xtp_subplotSgram(sgram, channels, nrows, ncols, epochs)

% plots spectrograms as output from xtp_mtspecgramc
% note this will plot a separate page for each epoch
%
% EXAMPLE: xtp_subplotSgram(sgram, channels, nrows, ncols)
% (nrows x ncols) must total the number of channels specified in channels.
% by default nrows = 4 and ncols = number of channels specified/4.

% 11/13/15 S Williams v1.2 1) get the min of the min and max of the max 
%                          2) reference channels appropriately for subplot
%                          3) transpose frequencies and times for sgram, as
%                          output from chronux is time x freq x channel
% 04/18/16 S Williams v1.3 allow to only plot specified epochs

if nargin<5
    epochs = 1:size(sgram.output,2);
end
numsegs = length(epochs);
numchannels = size(channels);
if nargin < 4
    if nargin < 3
        nrows = 4;
    end
    ncols = numchannels/nrows;
end
for s = 1:length(epochs)
    figure
    minval = min(min(min(sgram.output{epochs(s)}.S)));
    maxval = max(max(max(sgram.output{epochs(s)}.S)));
    caxis([log10(minval) log10(maxval)])
    for c=1:length(channels)
        subplot(nrows, ncols, c)
%         sh = surf(sgram.output{s}.t, sgram.output{s}.f, log10(sgram.output{s}.S(:,:,channels(c))'), log10(sgram.output{s}.S(:,:,channels(c))'));
%         set(sh, 'LineStyle', 'none');
% %         view(0,90);
% %         view(3);
% %         title(sprintf('channel %d',channels(c)))
        sh = imagesc(sgram.output{epochs(s)}.t, sgram.output{epochs(s)}.f, log10(sgram.output{epochs(s)}.S(:,:,channels(c))'));
        set(gca, 'YDir', 'normal')
        xlabel('Time (sec)')
        ylabel('Frequency (Hz)')
%         zlabel('log_1_0 (Power)')
        title(sgram.info.channelNames{channels(c)})
    end
    cbh = colorbar('Position', [0.05 0.3 0.03 0.4]);
    cbh.Label.String = 'Power(dB)';
    fth = xtp_title(sprintf('epoch %d', epochs(s)));
end
end
