function analResults = xtp_analyzePCAsurrogates(analysis, cohgram, numSurr)
% generates specified number of surrogate datasets, runs PCA on their
% coherograms and calls xtp_analyze on the PCA output.
% Example: analResults = xtp_analyzePCAsurrogates(analysis, cohgram, [numSurr])
%   Type help xtp_analyze for more info on ANALYSIS input argument.
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% 1.0   06/03/09    S. Williams     Created
% 1.1   07/25/09    S. Williams     Added status messages.
% 1.2   12/21/09    S. Williams     reinstated overall level .info field
%                                   and added .output field to contain
%                                   xtp_analyze output. Save surrogates and their PCAs to
%                                   cohgramSurr.mat file (with warning).
% DONT FORGET TO UPDATE VERSION NUMBER BELOW

global XTP_PCA_PARAMS

funcname = 'xtp_analyzePCAsurrogates';
version = 'v1.2';

if nargin < 3
    numSurr = 500;
end

savefile = [inputname(2) 'Surr.mat'];

if ~isempty(dir(savefile))
    fprintf('WARNING: This will overwrite surrogate coherogram and PCA data in the existing file %s.\n', savefile);
    if strcmpi(input('Continue[y/n]? ', 's'), 'y')
        delete(savefile)
        save(savefile, 'analysis');
    else
        fprintf ('Stopping at user request.\n')
        return
    end
else
    save(savefile, 'analysis');
end


analResults.info = cohgram.info;
analResults.info.datatype = 'ANALYSIS';
analResults.info.source = inputname(2);
analResults.info.generatedBy = funcname;
analResults.info.version = version;
analResults.info.rundate = clock;
analResults.info.analysis = analysis;

PCAparams = XTP_PCA_PARAMS;
PCAparams.pca_maxfreq = min(50,cohgram.info.cparams.Fs/4);
PCAparams.groupSwatches = 'groupAll';
PCAparams.logfile = 'surrogateAnalysisPCAlogfile.txt';

for surrNum = 1:numSurr
    clock
    fprintf('Creating surrogate %d of %d...\n',surrNum,numSurr);
    surrCG = xtp_surrCG(cohgram);
    fprintf('\tRunning PCA...\n');
    surrPCA = xtp_pca(surrCG, PCAparams);
    surrCGvarname = ['surrCG' num2str(surrNum)];
    surrPCAvarname = ['surrPCA' num2str(surrNum)];
    eval([surrCGvarname ' =  surrCG;']);
    eval([surrPCAvarname ' =  surrPCA;']);
    save(savefile, surrCGvarname, surrPCAvarname, '-append')
    clear surrCG
    for groupNum = 1:size(surrPCA.output,1)
        fprintf('\tAnalyzing swatchGroup %d...\n',groupNum);
        for cpNum = 1:size(surrPCA.output,2)
            analResults.output(groupNum,cpNum,surrNum)= xtp_analyze(analysis,surrPCA.output{groupNum,cpNum});
        end
    end
end
save(savefile, 'analResults','-append')
fprintf('Done. ');
clock