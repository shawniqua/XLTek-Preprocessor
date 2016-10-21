function pca = justPCA(cohgram, timeseries, PCAparams)
% takes coherograms and associated spectrograms and runs pca on them in an 
% attempt to parse them into state. Copied from parse_spec_demo, by
% JDVictor, modified for use with output from xtp_cohgramc.
%
%EXAMPLE:
%   pca = justPCA(cohgram, timeseries, [PCAparams])
% where PCAparams is a structure with the following fields:
%   .cohpair        index of the coherency pair to analyze (default 1)
%   .pca_submean    1 to demean data, 0 to not (this is presumably
%                   redundant) Default 0
%   .pca_ntoplot    # of principal components to plot (default 3)
%   .ifsurr         1 to generate surrogate data, 0 to not (default 0)
%
%   See also:  PHACOLOR, SURR_CORRGAU2, TEXT2SPECGRAM_DEMO.
%
% Dependencies: getinp
%
% CHANGE CONTROL
% Ver   Date        Person      Changes
% ----- ----------- ----------- -------------------------------------------
% 1.0   03/19/09    S. Williams Created from parse_spec_demo
% 1.1   03/26/09    S. Williams require separate passing of timeseries

global XTP_GLOBAL_PARAMS

min_pwr=10^-10; %minimum nonzero power
if (nargin<2 || ~isfield(PCAparams, 'ifsurr')) && XTP_GLOBAL_PARAMS.interactive
    ifsurr=getinp('1 to create and use surrogate data','d',[0 1],0);
end

fn = inputname(1);
nrows=6;
ncols=1;
NW = cohgram.info.cparams.tapers(1);
font_size = 6;
color_list=['r','g','b','m']; %for traces and histos
nswatches = size(cohgram.output, 1);

% create data input for surrogate data creation. Also append epochs of
% coherency and spectral data for PCA analysis.
data = [];
SG = [];
S12 = [];
if nargin < 2
    timeseries.data = cell(nswatches);  % just use dummy if not set... ifsurr cannot be set to 1 in this case.
end
for iswatch = 1:nswatches
    data = cat(1,data,timeseries.data{iswatch});
    SG = cat(2, SG, cat(3, cohgram.output{iswatch,cohpair}.S1, cohgram.output{iswatch,cohpair}.S2));
    S12 = cat(2, S12, cohgram.output{iswatch, cohpair}.S12);
end

if (ifsurr)
    %create surrogate data from data, taken as one huge swatch
    %subtract mean from each channel
    for ic=1:nchans
        data_demean(:,ic)=data(:,ic)-mean(data(:,ic));
    end
    disp('creating surrogate dataset');
%     params.tapers=[NW_list(end) NW_list(end)*2-1];
    params.tapers = cohgram.info.cparams.tapers;
    params.pad=0;
    params.Fs=1/dt;
    params.err=[1 .05];
%     winparams=[winsize_list(end) winsize_list(end)];
    winparams = cohgram.info.movingwin;
    % STW build surrogate data across all swatches with gaussian distribution 
    [C,phi,S12,S1,S2,t,f]=cohgramc(data_demean(:,1),data_demean(:,2),winparams,params);
    data_surr=surr_corrgau2(mean(S1),mean(S2),mean(S12),f,dt,npts*2); 
    data_use=data_surr(round(npts/2)+[1:npts],:);       % STW take only a subset of the surrogate data
    fn_aug=cat(2,fn,' surr');
else
    data_use=data;
    fn_aug=fn;
end

%% THIS FOR-LOOP NEEDS TO BE ELIMINATED.
% should do PCA on the entire accumulation of epochs at once

for iswatch=1:nswatches
    f = cohgram.output{iswatch,cohpair}.f;
    tvals = cohgram.output{iswatch,cohpair}.t;
    dt=(tvals(end)-tvals(1))/(length(tvals)-1);
    winsize = cohgram.info.movingwin(1);
    winstep = cohgram.info.movingwin(2);
%     winparams=[winsize winsize*winstep];
    f0=1./winsize;
    df=f0*(2*NW-1);

    pstring_p=sprintf('dt%5.1f df%4.2f NW%3.0f step %4.2f',winsize,df,NW,winstep);
    
%     plist=[1:npts_swatch]+(iswatch-1)*npts_swatch;
    plist = 1:length(cohgram.output{iswatch,cohpair}.t);
    pstring_d=sprintf('%s sw%3.0f',fn_aug,iswatch);
    tstring=cat(2,pstring_d,': ',pstring_p);
    %
    %calculate the coherograms and cross-spectrogram
    %
    % [C,phi,S12,S1,S2]=cohgramc(data_reshaped(:,iswatch,1),data_reshaped(:,iswatch,2),winparams,params);
    %
    %now do some PCA for the right column(s)
    %
    pca_datatypes=5; %number of kinds of pca analysis
    u=cell(1,pca_datatypes);
    s=cell(1,pca_datatypes);
    v=cell(1,pca_datatypes);
    for ipca=1:pca_datatypes
        fsample=[NW:(2*NW-1):length(f)];
        fsample=intersect(fsample,find(f<=pca_maxfreq)); %restrict frequencies if requested
        
        %skip plotting
        
        %set up the data for pca
        %
        pca_subsets=cell(0);
        switch ipca
            case {1}
                % x=log10(max(SG(:,fsample,ipca,iswatch),min_pwr));
                x=log10(max(SG(:,fsample,ipca),min_pwr));
                pca_subsets{1}=sprintf('S%1.0f',ipca);
            case {2}
                % x=log10(max(SG(:,fsample,ipca,iswatch),min_pwr));
                x=log10(max(SG(:,fsample,ipca),min_pwr));
                pca_subsets{1}=sprintf('S%1.0f',ipca);
            case 3
                % x=log10(max(SG(:,fsample,:,iswatch),min_pwr));
                x=log10(max(SG(:,fsample,:),min_pwr));
                x=reshape(x,size(x,1),size(x,2)*size(x,3));
                pca_subsets{1}='S1';
                pca_subsets{2}='S2';
            case 4
                x=log10(max(abs(S12(:,fsample)),min_pwr));
                pca_subsets{1}='abs(S12)';
            case 5
                % x=log10(max(SG(:,fsample,:,iswatch),min_pwr));
                x=log10(max(SG(:,fsample,:),min_pwr));
                x=reshape(x,size(x,1),size(x,2)*size(x,3));
                x=[x,log10(max(abs(S12(:,fsample)),min_pwr))];
                pca_subsets{1}='S1';
                pca_subsets{2}='S2';
                pca_subsets{3}='abs(S12)';
        end
        %set up labeling for each range of data used for pca
        pcalabel=pca_subsets{1};
        for ip=2:length(pca_subsets)
            pcalabel=cat(2,pcalabel,' ',pca_subsets{ip});
        end
        %subtract mean if requested
        if (pca_submean==1)
            x=x-repmat(mean(x,1),size(x,1),1);
            pcalabel=cat(2,pcalabel,' msub');
        end
        %note that size(x,2)=length(fsample)*length(pca_subsets)
        fvals=repmat(f(fsample),1,length(pca_subsets)); %frequency values 
        if (size(x,1)<=size(x,2))
            disp(sprintf(' pca on %20s not done because dim(x)= %4.0f %4.0f',pcalabel,size(x)));
        else
            %
            %do PCA
            %
            [u{ipca},s{ipca},v{ipca}]=svd(x,0);
            %u{ipca}(:,k) contains timecourse of kth principal component
            %v{ipca}(:,k) contains frequency-dependence of kth principal component
            ds=diag(s{ipca});
            ds=ds(1:length(fsample));
            disp(sprintf(' pca on %20s done.            dim(x)= %4.0f %4.0f',pcalabel,size(x)));
            %
            %align PC's so that the frequency-dependence is declining
            %
            ifinvert=-sign(fvals*v{ipca});
            v{ipca}=v{ipca}.*repmat(ifinvert,size(v{ipca},1),1);
            u{ipca}=u{ipca}.*repmat(ifinvert,size(u{ipca},1),1);
            %
            selpos=find(u{ipca}(:,1)>=0);
            selneg=find(u{ipca}(:,1)<0);
            %
            set(gcf,'Name',cat(2,tstring,' ',pcalabel));
            %
            %scree plot
            subplot(nrows,3*ncols,4);
            semilogy([1:length(fsample)],max(ds,min_pwr)/sum(diag(s{ipca})),'k.-');hold on;
            title(sprintf('pca on %s',pcalabel),'FontSize',font_size);
            set(gca,'XLim',[1 length(fsample)]);
            set(gca,'YLim',[10^-4,1]);
            set(gca,'FontSize',font_size);
            %
            %plot first pca_ntoplot PC's as lines and colormap
            %
            subplot(nrows,3*ncols,5);
            for ip=1:pca_ntoplot
                plot(-0.5+[1:size(x,2)],v{ipca}(:,ip),cat(2,color_list(ip),'.-'));hold on;
            end
            set(gca,'YLim',[-1 1]*max(abs(get(gca,'YLim'))));
            set(gca,'XLim',[0 size(x,2)]);
            for ip=2:length(pca_subsets)
                plot((ip-1)*length(fsample)*[1 1],get(gca,'YLim'),'k-');
            end
            set(gca,'XTick',length(fsample)*[1:length(pca_subsets)]);
            set(gca,'XTickLabel',sprintf('%4.1f',fvals(length(fsample)))); %matlab will repeat the label as needed
            set(gca,'FontSize',font_size);
            %
            subplot(nrows,3*ncols,6);
            vconsol=v{ipca}(:,[1:pca_ntoplot]); %rearrange v so that strips show each pc, then each subset
            vconsol=reshape(vconsol,[length(fsample) length(pca_subsets) pca_ntoplot]);
            vconsol=permute(vconsol,[1 3 2]);
            vconsol=reshape(vconsol,[length(fsample) pca_ntoplot*length(pca_subsets)]);
            imagesc(vconsol);set(gca,'YDir','normal');hold on;
            set(gca,'CLim',get(gca,'CLim')*[1 -0.1;0 1.1]); %make sure that last 10% of color range is not used so phacol can be used
            %
            for ip=2:length(pca_subsets)
                plot([1 1]*(0.5+(ip-1)*pca_ntoplot),get(gca,'YLim'),'k-');
            end
            set(gca,'XTick',0.5+pca_ntoplot*([1:length(pca_subsets)]-0.5));
            set(gca,'XTickLabel',pca_subsets);
            colorbar off;
            set(gca,'FontSize',font_size);
            %
            %plot first pca_ntoplot PC's as function of time
            %
            pcm=max(max(abs(u{ipca}(:,1:min(3,pca_ntoplot)))));
            subplot(nrows,ncols,ncols+2);
            for ip=1:pca_ntoplot
%                 plot(t-dt+t_start,pcm*(ip-(pca_ntoplot+1)/2)+u{ipca}(:,ip),cat(2,color_list(ip),'-'));hold on;
                plot(cohgram.output{iswatch,cohpair}.t,pcm*(ip-(pca_ntoplot+1)/2)+u{ipca}(:,ip),cat(2,color_list(ip),'-'));hold on;
%                 plot([tvals(plist(1))-dt,tvals(plist(end))],pcm*(ip-(pca_ntoplot+1)/2)*[1 1],'k-');hold on;
                plot([tvals(plist(1))-dt,tvals(plist(end))],pcm*(ip-(pca_ntoplot+1)/2)*[1 1],'k-');hold on;
            end
            xlabel('t (sec)','FontSize',font_size);
            set(gca,'XLim',[tvals(plist(1))-dt,tvals(plist(end))]);
%             set(gca,'Position',get(gca,'Position').*[1 1 0 1]+get(hspect,'Position').*[0 0 1 0]); %adjust x-axis fo raw traces
            set(gca,'FontSize',font_size);
            %
            % plot histograms of time series of PC's
            %
            for ip=1:min(3,pca_ntoplot)
                subplot(nrows,3*ncols,6*ncols+3+ip);
                hcounts=hist(u{ipca}(:,ip),pcm*[-0.95:.1:0.95]);
                hb=bar(pcm*[-0.95:.1:0.95],hcounts,1);
                set(hb,'FaceColor',color_list(ip));
                hold on;
                xlabel(sprintf('pc%1.0f',ip),'FontSize',font_size);
                set(gca,'XLim',[-pcm pcm]);
                set(gca,'FontSize',font_size);
            end
            %
            % plot projections into coordinate planes of time series of PC's
            %
            ip=0;
            for ip1=2:min(3,pca_ntoplot)
                for ip2=1:ip1-1
                    ip=ip+1;
                    subplot(nrows,3*ncols,9*ncols+3+ip);
                    plot(u{ipca}(selpos,ip1),u{ipca}(selpos,ip2),'r.'); hold on;
                    plot(u{ipca}(selneg,ip1),u{ipca}(selneg,ip2),'k.'); hold on;
                    xlabel(sprintf('pc%1.0f',ip1),'FontSize',font_size);
                    ylabel(sprintf('pc%1.0f',ip2),'FontSize',font_size);
                    set(gca,'XLim',[-pcm pcm]);
                    set(gca,'YLim',[-pcm pcm]);
                    axis equal;
                    axis square;
                    set(gca,'FontSize',font_size);
                end
            end
            %
            % 3d
            %
            if (pca_ntoplot>=3)
                ip1=1;
                ip2=2;
                ip3=3;
%                 subplot(nrows/2,ncols,(nrows/2-1)*ncols+2);
                subplot(nrows/2,ncols,nrows/2);
                plot3(u{ipca}(selpos,ip1),u{ipca}(selpos,ip2),u{ipca}(selpos,ip3),'r.'); hold on;
                plot3(u{ipca}(selneg,ip1),u{ipca}(selneg,ip2),u{ipca}(selneg,ip3),'k.'); hold on;
                xlabel(sprintf('pc%1.0f',ip1),'FontSize',font_size);
                ylabel(sprintf('pc%1.0f',ip2),'FontSize',font_size);
                zlabel(sprintf('pc%1.0f',ip3),'FontSize',font_size);
                set(gca,'XLim',[-pcm pcm]);
                set(gca,'YLim',[-pcm pcm]);
                set(gca,'ZLim',[-pcm pcm]);
                axis equal;
                axis vis3d;
                set(gca,'FontSize',font_size);
            end
        end %if size(x)
    end %ipca
    pca{iswatch}.u = u;
    pca{iswatch}.s = s;
    pca{iswatch}.v = v;
end %iswatch
end %function