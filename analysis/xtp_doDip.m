function dip = xtp_doDip(pca)
% calculates Hartigan dip statistic on the first primary component for all
% swatchGroups, channel pairs and pcatypes in the given PCA variable.
% EXAMPLE  dip = xtp_doDip(pca)
% output is a TxCPxG matrix of dip statistics, where:
%   T = number of pca_datatypes (datatype 3 = S1|S12, datatype 7 = C)
%   CP = number of channel pairs
%   G = number of swatchGroups
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0               S. Williams     created

[numSG numCP] = size(pca.output);
numPCAtypes = size(pca.info.PCAparams.pcaTypes.numSubsets);
dip = zeros(numPCAtypes,numCP,numSG);

for swatchGroup = 1:numSG
    for cp = 1:numCP
        for pcat = 1:numPCAtypes
            dip(pcat,cp,swatchGroup) = HartigansDipTest(pca.output{swatchGroup,cp}.u{pcat}(:,1));
        end
    end
end