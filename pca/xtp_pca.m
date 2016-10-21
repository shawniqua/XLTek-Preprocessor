function pca = xtp_pca(cohgram, PCAparams)
% takes coherograms and associated spectrograms and runs pca on them in an 
% attempt to parse them into state. Copied from parse_spec_demo, by
% JDVictor, modified for use with output from xtp_cohgramc.
%
%EXAMPLE:
%   pca = xtp_pca(cohgram, [PCAparams])
% where PCAparams is a structure with the following fields:
%   .pca_submean    1 to demean data, 0 to not (default 1)
%   .pca_maxfreq    maximum frequency to use for PCA calculations (default
%                   is the max frequency for the first epoch)
%   .pca_ntoplot    # of principal components to plot (default 3)
%   .ifsurr         1 to generate surrogate data, 0 to not (default 0)
%   .groupSwatches  'individual' to analyze all epochs separately (default)
%                   'groupAll' or 1:size(cohgram.output,1) to analyze all epochs
%                       as single group
%                   {[indexlist1], [indexlist2]...} to analyze epochs in
%                       groups as specified by the indexlists provided.
%   .logfile        name of output log file (defaults to stdout)
%
%   See also:  PHACOLOR, SURR_CORRGAU2, TEXT2SPECGRAM_DEMO.
%
% output is a structure with the followign fields:
%   .info   metadata
%   .output SG x CP cell array, with SG swatchGroups and CP channel pairs.
%           each cell has the following struct inside:
%               .sampled_f      the frequencies at which PCs were calculated
%               .t              the times at which PCs were calculated?
%               .tmarkers
%               .u              1xD cell array of PC values, one cell per
%                               PCA datatype. in each cell is a TxPC matrix
%                               with one column for each PC
%               .s              1xD cell array of
%               .v              1xD cell array of
% Dependencies: getinp
%
% CHANGE CONTROL
% Ver   Date        Person      Changes
% ----- ----------- ----------- -------------------------------------------
% 1.0   04/16/09    S. Williams Created from parse_spec_demo (3rd attempt)
% 1.1   04/16/09    S. Williams managed to get it to run & plot
% 2.0   04/17/09    S. Williams divorce pca calculation from pca plotting
% 2.1   04/20/09    S. Williams helptext: default pca_submean is 1.
%                               optional aggregation across epochs before
%                               running pca
% 2.2   04/21/09    S. Williams default groupSwatches sb 'individual', not
%                               'none'. store tmarkers indicating where
%                               inthe swatchGroup each swatch starts.
% 2.3   05/04/09    S. Williams store individual PCAlabels for each subset
% 2.4   05/04/09    S. Williams changes to support ifsurr = 1, use
%                               global default XTP_PCA_PARAMS if none
%                               given. BUT still limit pca_maxfreq based on
%                               cohgram. also support pca datatypes 6 & 7.
% 2.5   05/07/09    S. Williams save surrogate data to output variable                               
% 2.6   05/20/09    S. Williams add ztransform (atanh) of absolute value of
%                               coherence as pca_datatype#8
%2.6.1  05/21/09    S. Williams bugfix
% 2.7   05/22/09    S. Williams add atanh(phi+0.5) as a 9th pca datatype
% 2.8   05/22/09    S. Williams identify mean spectra & coherences across
%                               groups for surrogate data generation
% 2.9   06/04/09    S. Williams optionally redirect output to a logfile
%                               instead of stdout
funcname = 'xtp_pca.m';
version = 'v2.9';

global XTP_PCA_PARAMS

if nargin == 1 
    PCAparams = XTP_PCA_PARAMS;
    PCAparams.pca_maxfreq = min(PCAparams.pca_maxfreq, max(cohgram.output{1}.f));
end

if ~isfield(PCAparams,'logfile') || strcmpi(PCAparams.logfile, 'stdout')
    fout = 1;
else
    fout = fopen(PCAparams.logfile, 'a');
    if fout == -1
        message = sprintf('ERROR: cannot open logfile %s for writing.\n',PCAparams.logfile);
        disp(message);
        return;
    end
end
runtime = clock;
fprintf(fout, 'Running PCA (time: %s)\n',num2str(runtime));

%% record basic metadata
pca.info.datatype = 'PCA';
pca.info.source = inputname(1);
pca.info.generatedBy = funcname;
pca.info.version = version;
pca.info.rundate = clock;
pca.info.channelPairs = cohgram.info.cohPairList;
pca.info.channelNames = cohgram.info.channelNames;

%% resolve groupSwatches parameter before recording it
if ischar(PCAparams.groupSwatches)
    switch PCAparams.groupSwatches
        case 'individual'     %evaluate each swatch individually
            PCAparams.groupSwatches = num2cell(1:size(cohgram.output,1));
        case 'groupAll'      % evaluate all swatches as one big group
            PCAparams.groupSwatches = {1:size(cohgram.output,1)};
        otherwise
            fprintf(fout,'WARNING: unrecognized option %s for grouping of swatches. Evaluating swatches individually...\n', PCAparams.groupSwatches);
            PCAparams.groupSwatches = num2cell(1:size(cohgram.output,1));
    end
end

pca.info.PCAparams = PCAparams;

%% document PCA subsets
pca.info.PCAparams.pcaTypes.pcaLabels = {
    'S1' '' ''
    'S2' '' ''
    'S1' 'S2' ''
    'abs(S12)' '' ''
    'S1' 'S2' 'abs(S12)'
    'RxS12' 'IxS12' ''
    'C' '' ''
    'atanh(C)' '' ''
    'zPhi' '' ''
    };
pca.info.PCAparams.pcaTypes.numSubsets = [
    1
    1
    2
    1
    3
    2
    1
    1
    1
    ];


%% grouping of swatches for analysis
cohgram.outputMatrix = cell2mat(cohgram.output);
for cohpairnum = 1:size(cohgram.info.cohPairList,1)
    % identify mean of coherogram across swatched for surrogate data creation
    if PCAparams.ifsurr
        catS1 = cat(1,cohgram.outputMatrix(:,cohpairnum).S1);
        catS2 = cat(1,cohgram.outputMatrix(:,cohpairnum).S2);
        catS12 = cat(1,cohgram.outputMatrix(:,cohpairnum).S12);
        meanS1 = mean(catS1,1);
        meanS2 = mean(catS2,1);
        meanS12 = mean(catS12,1);
    end
    for swatchGroupNum = 1:length(PCAparams.groupSwatches)
        groupedCohgram.output{swatchGroupNum,cohpairnum}.C = cat(1,cohgram.outputMatrix(PCAparams.groupSwatches{swatchGroupNum},cohpairnum).C);
        groupedCohgram.output{swatchGroupNum,cohpairnum}.phi = cat(1,cohgram.outputMatrix(PCAparams.groupSwatches{swatchGroupNum},cohpairnum).phi);
        groupedCohgram.output{swatchGroupNum,cohpairnum}.S12 = cat(1,cohgram.outputMatrix(PCAparams.groupSwatches{swatchGroupNum},cohpairnum).S12);
        groupedCohgram.output{swatchGroupNum,cohpairnum}.S1 = cat(1,cohgram.outputMatrix(PCAparams.groupSwatches{swatchGroupNum},cohpairnum).S1);
        groupedCohgram.output{swatchGroupNum,cohpairnum}.S2 = cat(1,cohgram.outputMatrix(PCAparams.groupSwatches{swatchGroupNum},cohpairnum).S2);

        % time arrays are concatenated end to end.
        groupedCohgram.output{swatchGroupNum,cohpairnum}.t = cat(2,cohgram.outputMatrix(PCAparams.groupSwatches{swatchGroupNum},cohpairnum).t);    
        swatchLengths = zeros(1,length(PCAparams.groupSwatches{swatchGroupNum}));
        tmarkers = ones(1,length(PCAparams.groupSwatches{swatchGroupNum}));
        for swatchNumInGroup=1:length(PCAparams.groupSwatches{swatchGroupNum})
            swatchLengths(swatchNumInGroup) = length(cohgram.output{PCAparams.groupSwatches{swatchGroupNum}(swatchNumInGroup),cohpairnum}.t);
            tmarkers(swatchNumInGroup) = sum(swatchLengths(1:swatchNumInGroup-1))+1;    % indicate the starting index number for each of the swatches in the swatch group.
        end
        groupedCohgram.output{swatchGroupNum,cohpairnum}.tmarkers = tmarkers;

        % frequency array should be the same for all
        groupedCohgram.output{swatchGroupNum,cohpairnum}.f = cohgram.output{1,1}.f;
        % NO SUPPORT FOR CONFIDENCE LIMITS ON GROUPED DATA - IN THIS CASE
        % MUST USE XTP_AGGREGATE TO GROUP EPOCHS BEFORE CALCUATING COHGRAM.

        if PCAparams.ifsurr
            % create surrogate data for analysis
            dataset = groupedCohgram.output{swatchGroupNum, cohpairnum};
            surrNpts = size(dataset.C,1)*cohgram.info.cparams.Fs*cohgram.info.cparams.movingwin(1); %assumes nonoverlapping windows. 
            % data_surr = surr_corrgau2(mean(dataset.S1), mean(dataset.S2), mean(dataset.S12), dataset.f, 1/cohgram.info.cparams.Fs,surrNpts);  
            data_surr = surr_corrgau2(meanS1,meanS2,meanS12,dataset.f,1/cohgram.info.cparams.Fs,surrNpts);
            % original code multiplied number of samples by 2 - I have not
            % done that here.
            % data_use = data_surr(surrNpts+[1:2*surrNpts],:);     % not sure how to decide what data to use - this may have had to do with the epoch that was chosen?
            data_use = data_surr;
            % data_reshaped = reshape(data_use(1:npts_swatch*nswatch,:),npts_swatch,nswatch,nchans);  
            % here he reshaped it to S x E x C where S = # samples in
            % each epoch, E = # epochs, C = # channels. but it could be
            % epochs of different lengths so I'm not interested in that.
            % Instead I will run the coherogram on the full concatenated
            % list of epochs
            data_reshaped = data_use;
            cparams = cohgram.info.cparams;
            cparams.err(1) = 0;
            [surrCG.C surrCG.phi surrCG.S12 surrCG.S1 surrCG.S2 surrCG.t surrCG.f] = cohgramc(data_reshaped(:,1),data_reshaped(:,2),cparams.movingwin,cparams);
            surrCG.tmarkers = groupedCohgram.output{swatchGroupNum,cohpairnum}.tmarkers;
            pca.surrCG{swatchGroupNum,cohpairnum} = surrCG;
            groupedCohgram.output{swatchGroupNum,cohpairnum} = surrCG;
        end %ifsurr
    end
end
cohgram = rmfield(cohgram, 'outputMatrix');


%% set up and perform PCA for each specified channel pair and group of swatches

numPCAtypes = length(pca.info.PCAparams.pcaTypes.numSubsets);
NW = cohgram.info.cparams.tapers(1);
min_pwr=10^-10; %minimum nonzero power

for cohpairnum = 1:size(cohgram.info.cohPairList,1)
    channel1 = cohgram.info.channelNames{cohgram.info.cohPairList(cohpairnum,1)};
    channel2 = cohgram.info.channelNames{cohgram.info.cohPairList(cohpairnum,2)};
    for swatchGroupNum = 1:size(groupedCohgram.output,1)
        fprintf(fout,'\ncohpair: %s & %s\tswatchGroup #%d (swatches %s)\n',channel1, channel2, swatchGroupNum, num2str(PCAparams.groupSwatches{swatchGroupNum}));
        dataset = groupedCohgram.output{swatchGroupNum, cohpairnum};
        f = dataset.f;
        fsample=NW:(2*NW-1):length(f);    % indexes of 'independent' frequencies
        fsample=intersect(fsample,find(f<=PCAparams.pca_maxfreq)); %restrict frequencies if requested
        pca.output{swatchGroupNum,cohpairnum}.sampled_f = f(fsample);
        pca.output{swatchGroupNum,cohpairnum}.t = dataset.t;
        pca.output{swatchGroupNum,cohpairnum}.tmarkers = dataset.tmarkers;
        u=cell(1,numPCAtypes);
        s=cell(1,numPCAtypes);
        v=cell(1,numPCAtypes);
        
%% CREATE PCA DATATYPES HERE
        for pcaTypeNum = 1:numPCAtypes
            switch pcaTypeNum
                case 1
                    x=log10(max(dataset.S1(:,fsample),min_pwr));
                case 2
                    x=log10(max(dataset.S2(:,fsample),min_pwr));
                case 3
                    x=log10(max([dataset.S1(:,fsample) dataset.S2(:,fsample)],min_pwr));
                case 4
                    x=log10(max(abs(dataset.S12(:,fsample)),min_pwr));
                case 5
                    x=log10(max([dataset.S1(:,fsample) dataset.S2(:,fsample) abs(dataset.S12(:,fsample))],min_pwr));
                case 6
                    realS12 = real(dataset.S12(:,fsample));
                    realS12 = realS12-repmat(mean(realS12,2),1,size(realS12,2));
                    imagS12 = imag(dataset.S12(:,fsample));
                    imagS12 = imagS12-repmat(mean(imagS12,2),1,size(imagS12,2));
                    x=[realS12 imagS12];    % real & imaginary parts of crosspectrum, demeaned across frequencies                    
                case 7
                    x=dataset.C(:,fsample);
                case 8
                    x=atanh(dataset.C(:,fsample));
                case 9
                    x=atanh(dataset.phi(:,fsample)/(2*pi)-0.5);
            end
            numSubsets = pca.info.PCAparams.pcaTypes.numSubsets(pcaTypeNum);
            
%% END CREATE PCA DATATYPES SECTION
            
            if (PCAparams.pca_submean==1) %subtract mean across time samples if requested
                x=x-repmat(mean(x,1),size(x,1),1);  
            end
            fvals=repmat(f(fsample),1,numSubsets); %frequency values repeated for the number of pca subsets
            if (size(x,1)<=size(x,2)) %STW: if the number of timepoints < # frequencies (with replication for pca subtypes)
                fprintf(fout,' pca on %20s not done because dim(x)= %4.0f %4.0f',pca.info.PCAparams.pcaTypes.pcaLabels{pcaTypeNum},size(x));
            else    % do PCA!!
                [u{pcaTypeNum},s{pcaTypeNum},v{pcaTypeNum}]=svd(x,0);
                %u{pcaTypeNum}(t,k) contains timecourse of kth principal component
                % STW: i.e. the value of that PC given the frequency
                %      content of the signal at time t
                %v{pcaTypeNum}(:,k) contains frequency-dependence of kth principal component
                % STW: i.e. the amount of variance of that PC that is
                %      attributable to changes in frequency f
                
                fprintf(fout,' pca on %20s done.            dim(x)= %4.0f %4.0f',cat(2,pca.info.PCAparams.pcaTypes.pcaLabels{pcaTypeNum,:}),size(x));
                %
                %align PC's so that the frequency-dependence is declining
                %
                ifinvert=-sign(fvals*v{pcaTypeNum});
                v{pcaTypeNum}=v{pcaTypeNum}.*repmat(ifinvert,size(v{pcaTypeNum},1),1);
                u{pcaTypeNum}=u{pcaTypeNum}.*repmat(ifinvert,size(u{pcaTypeNum},1),1);
            end %if ok to do PCA for this type
        end %pcaTypeNum
        pca.output{swatchGroupNum,cohpairnum}.u = u;
        pca.output{swatchGroupNum,cohpairnum}.s = s;
        pca.output{swatchGroupNum,cohpairnum}.v = v;
    end %swatchGroupNum
end %cohpairnum
if fout ~= 1
    fclose(fout);
end
end %function

% 
% 
% swatchlist = 1:length(timeseries.data);
% min_pwr=10^-10; %minimum nonzero power
% pca_datatypes=5; %number of kinds of pca analysis
% NW=cohgram.info.cparams.tapers(1);
% pca_maxfreq = PCAparams.pca_maxfreq;
% npts_swatch = size(timeseries.data{1},1);
% cparams = cohgram.info.cparams;
% movingwin = cohgram.info.cparams.movingwin;
% f0=1./movingwin(1);
% df=f0*(2*NW-1);
% pstring_p=sprintf('dt%5.1f df%4.2f NW%3.0f step %4.2f',movingwin(1),df,NW,movingwin(2));
% nchans = size(timeseries.data{1},2);
% fn_aug = inputname(2);    %filename where the data was found, augmented with surrogate data if requested (surrogate data currently not supported).
% dt = 1; % is dt the time between successive timepoints or is it the time correlating to one winstep?
% color_list=['r','g','b','m']; %for traces and histos
% nrows = 6;
% ncols = 1;
% font_size = 6;
% 
% for iswatch = 1:length(timeseries.data) 
%     %reshape data array to (time points, trials, channel) THIS ASSUMES
%     %EQUAL LENGTH TRIALS, WHICH HE DOESN'T WANT!!!
%     data_reshaped(:,iswatch,:) = timeseries.data{iswatch};
% end
% 
% %subtract mean from each channel
% % UNNECESSARY - IT SHOULD HAVE ALREADY BEEN DETRENDED IN PREPROCESSING
% for ic=1:nchans
%     data_reshaped(:,:,ic)=data_reshaped(:,:,ic)-mean(mean(data_reshaped(:,:,ic)));
% end
% 
% %calculate spectra across all swatches, to get a uniform maximum
% SG=[];
% for iswatch=swatchlist
%     for ic=1:size(data_reshaped,3)
%         [SG(:,:,ic,iswatch),t,f]=mtspecgramc(data_reshaped(:,iswatch,ic),movingwin,cparams);
%     end %STW: spectrogram SG in format timepoints x frequency x channels x epochs. 
%         %THIS NEEDS TO MOVE TO CELL ARRAY FORMAT TO SUPPORT UNEQUAL LENGTH
%         %SEGMENTS. also note that t & f are getting written over every
%         %time - they also need to be recorded separately for each epoch.
% end
% % THIS IS ONLY USED IN THE COHGRAM PLOTTING
% % SGrange=[floor(min(log10(max(SG(:),min_pwr)))) ceil(max(log10(SG(:))))];
% 
% for iswatch = swatchlist
%     % NEED TO DEFINE PLIST IN CONTEXT OF UNEQUAL LENGTH SWATCHES. 
%     %list of points inthe swatch numbered as though swatches are end to
%     %end, and all the same length. it is used to determine which tvals to
%     %pick up. (may not be necessary.)
%     plist=[1:npts_swatch]+(iswatch-1)*npts_swatch;  
%     tvals = plist;
%     t_start=tvals(1+(iswatch-1)*npts_swatch);   
%     pstring_d=sprintf('%s sw%3.0f',fn_aug,iswatch);
%     tstring=cat(2,pstring_d,': ',pstring_p);
%     %
%     %calclate the coherograms and cross-spectrogram
%     %JUST USE THE CG PASSED IN TO THE PROGRAM. but need to account for >2
%     %channels. use the channels specified by cohpair (sb either a 2 element
%     %mtx or a scalar indicating which cohpair you want to use. interesting
%     %that we are not using the coherency amplitude or phase - only the
%     %cross-spectrum and the individual spectra.
%     [C,phi,S12,S1,S2]=cohgramc(data_reshaped(:,iswatch,1),data_reshaped(:,iswatch,2),movingwin,cparams);
%     %
%     %now do some PCA for the right column(s)
%     %
%     u=cell(1,pca_datatypes);
%     s=cell(1,pca_datatypes);
%     v=cell(1,pca_datatypes);
%     for ipca=1:pca_datatypes
%         fsample=[NW:(2*NW-1):length(f)];
%         fsample=intersect(fsample,find(f<=pca_maxfreq)); %restrict frequencies if requested
%         pca_subsets=cell(0);
%         switch ipca % ADJUST THESE TO USE COHEROGRAM INSTEAD. I'M NOT SURE WE NEED THE SPECTROGRAM.
%              case {1,2}
%                  %STW: spectrogram SG in format timepoints x
%                  %frequency x channels x epochs. ipca=1 => use
%                  %SG for the first channel. ipca=2 => use SG
%                  %for the 2nd channel  
%                 x=log10(max(SG(:,fsample,ipca,iswatch),min_pwr));   
%                 pca_subsets{1}=sprintf('S%1.0f',ipca);
%             case 3
%                 x=log10(max(SG(:,fsample,:,iswatch),min_pwr));
%                 x=reshape(x,size(x,1),size(x,2)*size(x,3)); 
%                 % reshape brings 3rd dimension into 2nd dimension, 
%                 % placing 2D matrices (1 for each channel) side by side
%                 pca_subsets{1}='S1';    
%                 pca_subsets{2}='S2';
%             case 4
%                 x=log10(max(abs(S12(:,fsample)),min_pwr));
%                 pca_subsets{1}='abs(S12)';
%             case 5
%                 x=log10(max(SG(:,fsample,:,iswatch),min_pwr));
%                 x=reshape(x,size(x,1),size(x,2)*size(x,3));
%                 x=[x,log10(max(abs(S12(:,fsample)),min_pwr))];
%                 pca_subsets{1}='S1';
%                 pca_subsets{2}='S2';
%                 pca_subsets{3}='abs(S12)';
%         end %switch
%         %set up labeling for each range of data used for pca THIS ONLY
%         %NEEDS TO BE DONE ONCE FOR ALL SWATCHES AND FOR ALL CHANNELS
%         pca.info.pcalabels{ipca}=pca_subsets{1};
%         for ip=2:length(pca_subsets)
%             pca.info.pcalabels{ipca}(ip)=pca_subsets{ip};
%         end
%         %subtract mean if requested
%         %STW: repmat replicates the matrix of means so it has
%         %the same dimensions as the data matrix.
%         %values at each cell of the data matrix are thus 
%         %reduced by the mean power across time at each frequency.
%         if (pca_submean==1)
%             x=x-repmat(mean(x,1),size(x,1),1);  
%             % pca.info.pcalabels=cat(2,pcalabel,' msub');   % not necessary
%             % as it will show in the PCAparams.
%         end
%         %note that size(x,2)=length(fsample)*length(pca_subsets)
%         fvals=repmat(f(fsample),1,length(pca_subsets)); %frequency values repeated for the number of pca subsets
%         if (size(x,1)<=size(x,2)) %STW: if the number of timepoints < # frequencies (with replication for pca subtypes)
%             disp(sprintf(' pca on %20s not done because dim(x)= %4.0f %4.0f',pcalabel,size(x)));
%         else
%             %
%             %do PCA
%             %
%             [u{ipca},s{ipca},v{ipca}]=svd(x,0); %STW: remember this is happening for each swatch & for each type of pca analysis
%             %u{ipca}(:,k) contains timecourse of kth principal component
%             %v{ipca}(:,k) contains frequency-dependence of kth principal component
%             ds=diag(s{ipca});
%             ds=ds(1:length(fsample));
%             disp(sprintf(' pca on %20s done.            dim(x)= %4.0f %4.0f',pcalabel,size(x)));
%             %
%             %align PC's so that the frequency-dependence is declining
%             %
%             ifinvert=-sign(fvals*v{ipca});
%             v{ipca}=v{ipca}.*repmat(ifinvert,size(v{ipca},1),1);
%             u{ipca}=u{ipca}.*repmat(ifinvert,size(u{ipca},1),1);
%         end %if ok to calculate pca
%     end %foreach pca_datatype
% end % foreach swatch
% end % function
% 
