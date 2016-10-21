function [spec specULT] = xtp_compareMTfunctions(dataULT, params)
% this function calls mtspectrumc and mtspectrumc_unequal_length_trials to
% calculate power spectra for a given dataset. It then plots the two
% spectra to compare visually. Data should be in the format
% samples x channels; as expected by mtspectrumc_unequal_length_trials. All
% epochs are the same length so as to work withi mtspectrumc. params should
% have the following fields, as required by the chronux manual: 
%         .tapers   - [NW K] where K is usually 2NW-1
%         .pad      - generally set to -1
%         .Fs       - in number of samples per second
%         .fpass    - [0 Fs/2]
%         .err      - [2 0.05]
%         .trialave - 1
%         .movingwin- in #seconds, for use with mtspectrumULT
%         .epochLength - in # of samples, will be used to generate sMarkers
%
% outputs: spec is a structure contining the spectra recovered when calling
% mtspectrumc. specULT is a structure containing fields corresponding to
% the output gained when calling mtspectrumc_unequal_length_trials.
%
% it is assumed that epochs are back to back and the same length, and that
% jackknife error bars are required (err(1) = 2).
%
% USAGE: [spec specULT] = xtp_compareMTfunctions(data, params);


%% mtspectrumc_unequal_length_trials
totalN = size(dataULT,1);
numEpochs = totalN/params.epochLength;
numChannels = size(dataULT,2);

sMarkers(:,1) = 1:params.epochLength:totalN;
sMarkers(:,2) = params.epochLength:params.epochLength:totalN;

[specULT.S specULT.f specULT.Serr] = mtspectrumc_unequal_length_trials(dataULT, params.movingwin, params, sMarkers);

%% rearrange data and run mtspectrumc
data = reshape(dataULT, [params.epochLength,numEpochs,numChannels]); % samples x epochs x channels
fprintf('Now running mtspectrumc.\nChannel: ')
for channel = 1:numChannels
    fprintf('%d...',channel);
    [spec.S(:,channel) spec.f(channel,:) spec.Serr(1:2,:,channel)] = mtspectrumc(data(:,:,channel),params);
end    

%% plot
figtitle = 'Comparison of mtspectrumc(BLUE) and mtspectrumc\_unequal\_length\_trials(RED) output (Click each plot to enlarge)';
figure('Name', figtitle)
for channel = 1:numChannels
    if numChannels > 1
        subplot(ceil(numChannels/4),4,channel)
    end
    h1 = plot(spec.f(channel,:), 10*log10(spec.S(:,channel)),'b','LineWidth',2);
    hold on
    plot(spec.f(channel,:), 10*log10(spec.Serr(1:2,:,channel)),'b')
    h2 = plot(specULT.f, 10*log10(specULT.S(:,channel)), 'r', 'LineWidth', 2);
    plot(specULT.f, 10*log10(specULT.Serr(1:2,:,channel)),'r')
    % flowers
    legend([h1 h2], 'mtspectrumc', 'unequal\_length\_trials')
    title(sprintf('Channel %d',channel), 'FontSize', 14)
    ylabel('10*log10(power)')
    xlabel('frequency (Hz)')
end
allowaxestogrow
