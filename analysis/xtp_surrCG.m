function surrCG = xtp_surrCG(cohgram)
% generates the coherogram for a surrogate dataset given an input CG. 
% EXAMPLE: surrCG = xtp_surrCG(cohgram)
%
% Change Control:
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   06/03/09    S. Williams     Created.
% 1.1   08/06/09    S. Williams     no error bars calculated on surrogate
%                                   CGs
%DONT FORGET TO UPDATE VERSION NUMBER BELOW.

funcname = 'xtp_surrCG';
version = 'v1.1';

surrCG = rmfield(cohgram,'output');
surrCG.info.source = inputname(1);
surrCG.info.generatedBy = funcname;
surrCG.info.version = version;
surrCG.info.rundate = clock;

cparams = cohgram.info.cparams;

cohgram.outputMatrix = cell2mat(cohgram.output);
numSwatches = size(cohgram.output,1);
% could probably reshape and run this as one set of commands instead of in
% a for loop
for cohpairnum = 1:size(cohgram.output,2)
    catS1 = cat(1,cohgram.outputMatrix(:,cohpairnum).S1);
    catS2 = cat(1,cohgram.outputMatrix(:,cohpairnum).S2);
    catS12 = cat(1,cohgram.outputMatrix(:,cohpairnum).S12);
    meanS1 = mean(catS1,1);
    meanS2 = mean(catS2,1);
    meanS12 = mean(catS12,1);
    surrogateData = cell(numSwatches,1);
    for swNum = 1:numSwatches
        % need to verify choice of frequency 
        % need to identify the appropriate surrNpts to use.
        surrNpts = size(cohgram.output{1,1}.C,1)*cparams.movingwin(1)*cparams.Fs;
        surrogateData{swNum,1}= surr_corrgau2(meanS1,meanS2,meanS12,cohgram.output{1,1}.f,1/cparams.Fs,surrNpts);   % they will be cells stacked on top of each other
    end
    surrogateData = cell2mat(surrogateData);    % TSxC matrix, where TS = total samples across all epochs & C = channels (C=2)
    surrogateData = reshape(surrogateData,[surrNpts numSwatches 2]); % SxExC, where S is number of samples for a single epoch, E = #epochs, C=2
    cparams.trialave = 0;
    [C phi S12 S1 S2 t f] = cohgramc(surrogateData(:,:,1),surrogateData(:,:,2),cparams.movingwin,cparams);
    cparams.trialave = cohgram.info.cparams.trialave;
    
    for swNum = 1:numSwatches
        surrCG.output{swNum,cohpairnum}.C = C(:,:,swNum);
        surrCG.output{swNum,cohpairnum}.phi = phi(:,:,swNum);
        surrCG.output{swNum,cohpairnum}.S12 = S12(:,:,swNum);
        surrCG.output{swNum,cohpairnum}.S1 = S1(:,:,swNum);
        surrCG.output{swNum,cohpairnum}.S2 = S2(:,:,swNum);
        surrCG.output{swNum,cohpairnum}.t = t;
        surrCG.output{swNum,cohpairnum}.f = f;
    end
    clear surrogateData
end
