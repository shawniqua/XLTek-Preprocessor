%xtp_build_environment
%
%this function creates the headboxes and headbox_montages and saves the
%environment to the xtp_environment.mat file. No input parameters.
%
%Change log:
%Ver Date     Person            Changes
%--- -------  ----------------- -------------------------------------------
%1.0 10/2/08  S. Williams       v1 - Created
%1.1 10/18/08 S. Williams       v2 - changed montage structure to eliminate
%                               middle level, made variables global, changed
%                               from function to script, added
%                               XTP_GLOBAL_PARAMS
%1.2 10/19/08 S. Williams       added 'EK DB 12 Bipolar Montage'
%1.3 10/21/08 S. Williams       added XTP_CHRONUX_PARAMS
%1.4 10/24/08 S. Williams       Revised names to HB Montages to include
%                               headbox name. Removed save xtp_environment,
%                               updated XTP_GLOBAL_PARAMS to reflect new
%                               standard for prefiltering parameter (in
%                               v1.2 of xtp_prefilter)
%1.5 10/31/08 S. Williams       added switches to XTP_GLOBAL_PARAMS to
%                               control calling of xtp_readXLTfile,
%                               xtp_cutSnippets and xtp_montage
%1.6 12/01/08 S. Williams       renamed X1-X10 in EK DB12 Bipolar Montage
%                               to match actual locations
%1.7 12/11/08 S. Williams       ensure base workspace has automatic access
%                               to global variables
%1.8 01/13/09 S.Williams        add creation of coherency pairs and
%                               global interactive flag
%1.9 01/25/09 S. Williams       changed default chronux parameters fpass
%                               to [0 100] from [0 50] and errorbars to
%                               jackknife (2) from theoretical (1)
%2.0 01/07/09 S. Williams       added pair list to XTP_COHERENCY_PAIRS for
%                               EMU headbox
%2.1 02/18/09 S. Williams       add XTP_CONVERSION_FACTORS, coherency pairs
%                               for EK DB 12, and XTP_GLOBAL_PARAMS.units
%2.2 03/01/09 S. Williams       added plotting locations for leads on
%                               XTP_HEADBOXES (not including X1-X10)
%2.3 03/01/09 S. Williams       changed lead_list for Mobee 32 headboox to
%                               include real labels for X1-X10 (per EK DB)
%2.4 03/10/09 S. Williams       fix label on xtp_hb_montages(3)
%2.5 03/11/09 S. Williams       added XTP_GLOBAL_PARAMS.epochListFile
%2.6 03/20/09 V. GDjokic        added pair lists to XTP_COHERENCY_PAIRS for
%                               Left vs. Right Analysis
%2.7 03/27/09 S. Williams       Added headbox (3) & DB montage (4) for use 
%                               with Laurey's EEG
%2.8 03/27/09 V. GDjokic        Renamed XTP_COHERENCY Pairs 4&5
%2.9 03/31/09 V. GDjokic        Added XTP_HB_MONTAGES(5)&(6)
%3.0 04/10/09 S. Williams       Added unipolar (vanilla) montages for each
%                               headbox, added montage reference to
%                               coherency pairs, added coherency pair lists
%                               referencing DB montages (pairs with
%                               independent channels, ignoring midline)
%3.1 04/13/09 S. Williams       add movingwin to XTP_CHRONUX_PARAMS
%3.2 04/23/09 S. Williams       add montage #10
%3.3 04/23/09 S. Williams       add Headbox #4, Montage #11 & 12
%3.4 04/24/09 S. Williams       add Headbox #5 for TW04 data (EMU36,
%                               exported from Browser)
%3.5 04/29/09 S. Williams       add Headbox #6 & montages 15 & 16 for 
%                               EK DB12 data exported from NDB 
%3.6 04/30/09 S. Williams       added Montage #17 for Mobee32 channels
%                               referenced to Pz, #18 for Mobee32 channels
%                               referenced to hemispheric average, and
%                               coherency pair lists #7 & #8 respectively
%3.7 05/05/09 S. Williams       fix channel name for montage #18, channel 1
%3.8 05/06/09 S. Williams       add XTP_PCA_PARAMS global default.
%3.9 05/14/09 S. Williams       add average common reference montage for
%                               mobee 32, DB. Removed references to Fz, Cz
%                               and Pz in cohpairs(8). Added cohpairs (9)
%4.0 05/16/09 S. Williams       completed cohpairs(19) 
%4.2 05/22/09 S. Williams       added cohpairs (20)
%4.3 05/26/09 A. Goldfine       added contralateral pairs to cohpairs (17) 
%4.4 05/26/09 S. Williams       fixed cohpairs(9) to compare Fz/Cz and
%                               Cz/Pz instead of Fp1/O1 and Fp2/O2, changed
%                               XTP_COHERENCY_PAIRS(11) to #10
%4.5 05/27/09 A. Goldfine       Added Montage 20 (EMU 36 Pz Ref) and Coh
%                               Pair 11.
%4.6 05/29/09 S. Williams       removed references to A1 and A2 from
%                               montage #3. created cohpairs#12
%4.7 06/04/09 S. Williams       created new environment variable
%                               XTP_PLOT_LOCATIONS
%4.8 06/05/09 S. Williams       Add logfile parameter to XTP_PLOT_LOCATIONS
%4.9 06/25/09 S. Williams       Add EMGcutoff to XTP_GLOBAL_PARAMS
%5.0 06/28/09 S. Williams       Add cohpairs #13
%5.1a 09/09/09 A. Goldfine       Add Montage 21 and HB 7 for Neonatal
                                %montage from browser
%5.2a 10/20/09 AG               Add HB 8 for EMU 40
%5.3a 12/10/09 AG               Added montage #22 - EMU40 bipolar
%5.4  01/23/10 S. Williams      (merge with v5.4s) Added cohpairs #14-#18,
%                               changed default PCAparams grouping to
%                               'groupAll'.
%5.5  01/23/10 S. Williams      added montage #23 (EMU40 including occipital channels), 
%                               cohpairs #19 (interhemispheric for EMU40)
%                               and cohpairs #20 (intrahemispheric EMU40)
%5.6  05/25/10 S. Williams      added EGI midline headbox
%5.7  05/27/10 S. Williams      added EGI saggital midline headbox (prev
%                               was coronal midline)
%5.8s 03/11/11 S. Williams      updated plotLocations of XTP_HEADBOXES (and
%                               by proxy, XTP_PLOT_LOCATIONS)
%6.0s 03/26/11 S. Williams      adding plotLocations field to
%                               XTP_HB_MONTAGES, calculated based on
%                               XTP_HEADBOXES plot locations. also added
%                               plotLocations for XTP_HEADBOXES(8)
%6.1s 12/05/13 S. Williams      Added XTP_HEADBOXES(11) for NK exports
%6.2s 12/10/13 S. Williams      XTP_HB_MONTAGES(24) for NK exports
%6.3s 03/07/14 S. Williams      added XTP_HEADBOXES(12) AND
%                               XTP_HB_MONTAGES(25) for additional NK
%                               exports
%6.4s 03/11/14 S. Williams      added 2 vanilla montages (26 & 27) for the
%                               new NK headboxes (11 & 12) respectively.
%6.5s 03/20/14 S. Williams      add new montages for NK/average common
%                               reference, AvCommRef-1 and hemispheric
%                               common reference -1.
%6.6s 03/22/14 S. Williams      add headbox 13 and montage 34,35 for ref=0v
%                               and corresponding vanilla and AvCommRef-1
%                               montages, adjusted lead_lists to have only
%                               the lead names that are actually in the
%                               montages (not the extra ones X1, A1, A2)
%6.7s 11/13/15 S. Williams      add headbox 14, hb_montage #36, cohpair #21
%6.8s 11/16/15 S. Williams      add hb_montage #37 (bipolar for natus)
%6.9s 07/04/16 S. Williams      add hb_montage #38 bipolar channels of
%                               interest for SVF05
%% start
function xtp_build_environment()

%% clear everything 
clear global XTP_GLOBAL_PARAMS XTP_CHRONUX_PARAMS XTP_PCA_PARAMS XTP_HEADBOXES XTP_HB_MONTAGES XTP_COHERENCY_PAIRS XTP_CONVERSION_FACTORS XTP_ENVIRONMENT_VERSION XTP_PLOT_LOCATIONS

%% declare global variables
cmd = 'global XTP_GLOBAL_PARAMS XTP_CHRONUX_PARAMS XTP_PCA_PARAMS XTP_HEADBOXES XTP_HB_MONTAGES XTP_COHERENCY_PAIRS XTP_CONVERSION_FACTORS XTP_ENVIRONMENT_VERSION XTP_PLOT_LOCATIONS';
eval(cmd);
evalin('base', cmd);

%% set environment version
XTP_ENVIRONMENT_VERSION = 'v6.8s';

%% set global parameters
XTP_GLOBAL_PARAMS.interactive = 1;      % may be used to control verbosity during runs
XTP_GLOBAL_PARAMS.readXLTfile = 1;
XTP_GLOBAL_PARAMS.cutSnippets = 1;
XTP_GLOBAL_PARAMS.epochListFile = 'epochlist.txt';
XTP_GLOBAL_PARAMS.units = 'uV';
XTP_GLOBAL_PARAMS.montageData = 1;
XTP_GLOBAL_PARAMS.headboxID = 1;
XTP_GLOBAL_PARAMS.HBmontageID = 1;
XTP_GLOBAL_PARAMS.prefiltering = 'linear';
XTP_GLOBAL_PARAMS.applyLPF = 1;
XTP_GLOBAL_PARAMS.LPFalgorithm = 'butter';
XTP_GLOBAL_PARAMS.LPForder = 3;
XTP_GLOBAL_PARAMS.LPFfrequency = 70;
XTP_GLOBAL_PARAMS.applyHPF = 1;
XTP_GLOBAL_PARAMS.HPFalgorithm = 'butter';
XTP_GLOBAL_PARAMS.HPForder = 3;
XTP_GLOBAL_PARAMS.HPFfrequency = 1;
XTP_GLOBAL_PARAMS.applyNotchFilter = 1;
XTP_GLOBAL_PARAMS.notchAlgorithm = 'butter';
XTP_GLOBAL_PARAMS.notchOrder = 3;
XTP_GLOBAL_PARAMS.notchFreq = 60;
XTP_GLOBAL_PARAMS.EMGcutoff = 1;

XTP_CHRONUX_PARAMS.tapers = [3 5];
XTP_CHRONUX_PARAMS.Fs = 200;
XTP_CHRONUX_PARAMS.fpass = [0 100];
XTP_CHRONUX_PARAMS.pad = 1;
XTP_CHRONUX_PARAMS.err = [2 0.05];
XTP_CHRONUX_PARAMS.trialave = 1;
XTP_CHRONUX_PARAMS.movingwin = [1 1];

XTP_PCA_PARAMS.pca_maxfreq = 50;
XTP_PCA_PARAMS.pca_submean = 1;
XTP_PCA_PARAMS.pca_ntoplot = 3;
XTP_PCA_PARAMS.ifsurr = 0;
XTP_PCA_PARAMS.groupSwatches = 'groupAll';
XTP_PCA_PARAMS.logfile = 'PCAlogfile.txt';

%% create headboxes (channel lists)
XTP_HEADBOXES(1).name = 'MOBEE 32 Headbox';
XTP_HEADBOXES(1).num_leads = 35;
XTP_HEADBOXES(1).lead_list = {
'REF' %1
'FP1'
'F7'
'T3'
'A1'    %5
'T5'
'O1'
'F3'
'C3'
'P3'    %10
'FPZ'
'FZ'
'CZ'
'PZ'
'FP2'   %15
'F8'
'T4'
'A2'
'T6'
'O2'    %20
'F4'
'C4'
'P4'
'AF7'
'AF8'   %25
'FC5'
'FC6'
'FC1'
'FC2'
'CP5'   %30
'CP6'
'CP1'
'CP2'
'OSAT'
'PR' }; %35
XTP_HEADBOXES(1).plotLocations = [
    0       0;
    -0.15   0.9;
    -0.75   0.6;
    -0.9    0;
    -1.1    0;
    -0.75   -0.6;
    -0.15   -0.9;
    -0.4    0.425;
    -0.45   0;
    -0.4    -0.425;
    0       0.95;
    0       0.4;
    0       0;
    0       -0.4;
    0.15    0.9;
    0.75    0.6;
    0.9     0;
    1.1     0;
    0.75    -0.6;
    0.15    -0.9;
    0.4     0.425;
    0.45    0;
    0.4     -0.425;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0   ];
% create locations for AF7, AF8, etc as fn of other leads (approximate)
fromIndices = [3 15 3 22 8 13 6 22 10 13];
toIndices = [2 16 9 16 13 21 9 19 13 23];
XTP_HEADBOXES(1).plotLocations(24:33,:) = ...
    XTP_HEADBOXES(1).plotLocations(fromIndices,:) + 0.5*(XTP_HEADBOXES(1).plotLocations(toIndices,:) - XTP_HEADBOXES(1).plotLocations(fromIndices,:));
clear fromIndices toIndices

XTP_HEADBOXES(2).name = '36 channel EMU Headbox';
XTP_HEADBOXES(2).num_leads = 36;
XTP_HEADBOXES(2).lead_list = {
'AC1'
'AC2'
'REF'
'FP1'
'F7'
'T3'
'T5'
'O1'
'F3'
'C3'
'P3'
'FZ'
'CZ'
'PZ'
'F4'
'C4'
'P4'
'FP2'
'F8'
'T4'
'T6'
'O2'
'AC23'
'AC24'
'AC25'
'AC26'
'AC27'
'AC28'
'AC29'
'AC30'
'AC31'
'AC32'
'DC1'
'DC2'
'DC3'
'DC4' };
XTP_HEADBOXES(2).plotLocations = [
    -1.1    0;
    1.1     0;
    0       0;
    -0.15   0.9;
    -0.75   0.6;
    -0.9    0;
    -0.75   -0.6;
    -0.15   -0.9;
    -0.4    0.425;
    -0.45   0;
    -0.4    -0.425;
    0       0.4;
    0       0;
    0       -0.4;
    0.4     0.425;
    0.45    0;
    0.4     -0.425;
    0.15    0.9;
    0.75    0.6;
    0.9     0;
    0.75    -0.6;
    0.15    -0.9;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0;
    0   0   ];
XTP_HEADBOXES(3).name = 'Generic EEG 19 leads';
XTP_HEADBOXES(3).num_leads = 19;
XTP_HEADBOXES(3).lead_list = {
    'Fp1'
    'Fp2'
    'F7'
    'F3'
    'Fz'
    'F4'
    'F8'
    'T3'
    'C3'
    'Cz'
    'C4'
    'T4'
    'T5'
    'P3'
    'Pz'
    'P4'
    'T6'
    'O1'
    'O2' };
XTP_HEADBOXES(3).plotLocations = [
    -0.15    0.9
     0.15    0.9
    -0.75    0.6
    -0.4     0.425
     0       0.4
     0.4     0.425
     0.75    0.6
    -0.9     0
    -0.45    0
     0       0
     0.45    0
     0.9     0
    -0.75   -0.6
    -0.4    -0.425
     0      -0.4
     0.4    -0.425
     0.75   -0.6
    -0.15   -0.9
     0.15   -0.9];
XTP_HEADBOXES(4).name = 'Generic 19 Lead HB for Mobee 32 Data Exported using Browser LBP International 10-20 View';
XTP_HEADBOXES(4).num_leads = 19;
XTP_HEADBOXES(4).lead_list = {
    'Fp1'
    'F7'
    'T3'
    'T5'
    'O1'
    'F3'
    'C3'
    'P3'
    'Fz'
    'Cz'
    'Pz'
    'Fp2'
    'F8'
    'T4'
    'T6'
    'O2' 
    'F4'
    'C4'
    'P4' };
XTP_HEADBOXES(4).plotLocations = [
    -0.15    0.9
    -0.75    0.6
    -0.9     0
    -0.75   -0.6
    -0.15   -0.9
    -0.4     0.425
    -0.45    0
    -0.4    -0.425
     0       0.4
     0       0
     0      -0.4
     0.15    0.9
     0.75    0.6
     0.9     0
     0.75   -0.6
     0.15   -0.9
     0.4     0.425
     0.45    0
     0.4    -0.425];
XTP_HEADBOXES(5).name = 'Generic 19 Lead HB for EMU 36 Data Exported using Browser LBP International 10-20 View';
XTP_HEADBOXES(5).num_leads = 19;
XTP_HEADBOXES(5).lead_list = {
    'Fp1'
    'F7'
    'T3'
    'T5'
    'O1'
    'F3'
    'C3'
    'P3'
    'Fz'
    'Cz'
    'Pz'
    'F4'
    'C4'
    'P4'
    'Fp2'
    'F8'
    'T4'
    'T6'
    'O2'
     };
XTP_HEADBOXES(5).plotLocations = [
    -0.15    0.9
    -0.75    0.6
    -0.9     0
    -0.75   -0.6
    -0.15   -0.9
    -0.4     0.425
    -0.45    0
    -0.4    -0.425
     0       0.4
     0       0
     0      -0.4
     0.4     0.425
     0.45    0
     0.4    -0.425
     0.15    0.9
     0.75    0.6
     0.9     0
     0.75   -0.6
     0.15   -0.9
     ];

XTP_HEADBOXES(6).name = 'Mobee 32 Data exported from NDB using EK DB12 montage';
XTP_HEADBOXES(6).num_leads = 29;
XTP_HEADBOXES(6).lead_list = {
    'Fp1'
    'F7'
    'T3'
    'T5'
    'O1'
    'F3'
    'C3'
    'P3'
    'Fz'
    'Cz'
    'Pz'
    'Fp2'
    'F8'
    'T4'
    'T6'
    'O2'
    'F4'
    'C4'
    'P4'
    'AF7'
    'AF8'
    'FC5'
    'FC6'
    'FC1'
    'FC2'
    'CP5'
    'CP6'
    'CP1'
    'CP2'
};
XTP_HEADBOXES(6).plotLocations = [
    -0.15   0.9;
    -0.75   0.6;
    -0.9    0;
    -0.75   -0.6;
    -0.15   -0.9;
    -0.4    0.425;
    -0.45   0;
    -0.4    -0.425;
    0       0.4;
    0       0;
    0       -0.4;
    0.15    0.9;
    0.75    0.6;
    0.9     0;
    0.75    -0.6;
    0.15    -0.9;
    0.4     0.425;
    0.45    0;
    0.4     -0.425;
    -0.5    0.75;
     0.5    0.75;
    -0.65   0.3;
     0.65   0.3;
    -0.1    0.28;
     0.1    0.28;
    -0.65  -0.3;
     0.65  -0.3;
    -0.1   -0.28;
     0.1    0.28;
];

XTP_HEADBOXES(7).name = 'Mobee 32 Data exported from NDB using Neonatal montage';
XTP_HEADBOXES(7).num_leads = 10;
XTP_HEADBOXES(7).lead_list = {
    'Fp1'
    'T3'
    'O1'
    'C3'
    'Fz'
    'Cz'
    'Fp2'
    'T4'
    'O2'
    'C4'
    };

XTP_HEADBOXES(8).name = 'EMU40 +18';
XTP_HEADBOXES(8).num_leads = 46;
XTP_HEADBOXES(8).lead_list = {
    'Fp1';'F7';'T3';'T5';'O1';'F3';'C3';'P3';'EMGref';'Fz';'Cz';'Fp2';'F8';'T4';'T6';'O2';'F4';'C4';'P4';'EMG';'FPz';'Pz';'AF7';'AF8';'FC5';'FC6';'FC1';'FC2';'CP5';'CP6';'CP1';'CP2';'PO7';'PO8';'F1';'F2';'CPz';'POz';'Oz';'EKG';'DC1';'DC2';'DC3';'DC4';'OSAT';'PR'};
XTP_HEADBOXES(8).plotLocations = [
    -0.1500    0.9000
   -0.7500    0.6000
   -0.9000         0
   -0.7500   -0.6000
   -0.1500   -0.9000
   -0.4000    0.4250
   -0.4500         0
   -0.4000   -0.4250
         0         0
         0    0.4000
         0         0
    0.1500    0.9000
    0.7500    0.6000
    0.9000         0
    0.7500   -0.6000
    0.1500   -0.9000
    0.4000    0.4250
    0.4500         0
    0.4000   -0.4250
         0         0
         0    0.9500
         0   -0.4000
   -0.4500    0.7500
    0.4500    0.7500
   -0.6000    0.3000
    0.6000    0.3000
   -0.2000    0.2125
    0.2000    0.2125
   -0.6000   -0.3000
    0.6000   -0.3000
   -0.2000   -0.2125
    0.2000   -0.2125
   -0.4750   -0.7500
    0.4750   -0.7500
   -0.2000    0.4125
    0.2000    0.4125
         0   -0.2000
         0   -0.6000
         0   -0.8000
         0         0
         0         0
         0         0
         0         0
         0         0
         0         0
         0         0];
     
XTP_HEADBOXES(9).name = 'EGI coronal midline leads';
XTP_HEADBOXES(9).num_leads = 21;
XTP_HEADBOXES(9).lead_list = {
     'E45'    'E52'    'E59'    'E64'    'E65'    'E69'    'E70'    'E73'    'E82'    'E132'    'E182'    'E183' 'E184'    'E193'    'E194'    'E202'    'E217'    'E218'    'E229'    'E256'    'E257'}';

XTP_HEADBOXES(10).name = 'EGI sagittal midline leads';
XTP_HEADBOXES(10).num_leads = 13;
XTP_HEADBOXES(10).lead_list = {
     'E8'    'E15'    'E21'    'E26'    'E31'    'E81'    'E90'    'E101'    'E119'    'E126'    'E137'    'E147' 'E257'}';

XTP_HEADBOXES(11).name = 'NK refA1<>A2 export';
XTP_HEADBOXES(11).num_leads = 20;
XTP_HEADBOXES(11).lead_list = {
     'Fp1'    'F7'    'T3'    'T5'    'Fp2'    'F8'    'T4'    'T6'    'F3'    'C3'    'P3'    'O1' 'F4'    'C4'    'P4'    'O2'    'Fz'    'Cz'    'Pz'    'X1'}';

XTP_HEADBOXES(12).name = 'NK REF export';
XTP_HEADBOXES(12).num_leads = 25;
XTP_HEADBOXES(12).lead_list = {'FP1' 'F7' 'F9' 'T7' 'A1' 'P7' 'O1' 'F3' 'C3' 'P3' 'FP2' 'F8' 'F10' 'T8' 'A2' 'P8' 'O2' 'F4' 'C4' 'P4' 'FZ' 'CZ' 'PZ' 'EKG1' 'EKG2'}';

XTP_HEADBOXES(13).name = 'NK 0V export';
XTP_HEADBOXES(13).num_leads = 22;
XTP_HEADBOXES(13).lead_list = {
     'Fp1'    'F7'    'T3'    'T5'    'Fp2'    'F8'    'T4'    'T6'    'F3'    'C3'    'P3'    'O1' 'F4'    'C4'    'P4'    'O2'    'Fz'    'Cz'    'Pz'    'X1-X2' 'A1' 'A2'}';

XTP_HEADBOXES(14).name = 'Natus 65535';
XTP_HEADBOXES(14).num_leads = 128;
XTP_HEADBOXES(14).lead_list = { 
     'CH001'; 'CH002'; 'CH003'; 'CH004'; 'CH005'; 'CH006'; 'CH007'; 'CH008'; 'CH009'; 'CH010';...
     'CH011'; 'CH012'; 'CH013'; 'CH014'; 'CH015'; 'CH016'; 'CH017'; 'CH018'; 'CH019'; 'CH020';...
     'CH021'; 'CH022'; 'CH023'; 'CH024'; 'CH025'; 'CH026'; 'CH027'; 'CH028'; 'CH029'; 'CH030';...
     'CH031'; 'CH032'; 'CH033'; 'CH034'; 'CH035'; 'CH036'; 'CH037'; 'CH038'; 'CH039'; 'CH040';...
     'CH041'; 'CH042'; 'CH043'; 'CH044'; 'CH045'; 'CH046'; 'CH047'; 'CH048'; 'CH049'; 'CH050';...
     'CH051'; 'CH052'; 'CH053'; 'CH054'; 'CH055'; 'CH056'; 'CH057'; 'CH058'; 'CH059'; 'CH060';...
     'CH061'; 'CH062'; 'CH063'; 'CH064'; 'CH065'; 'CH066'; 'CH067'; 'CH068'; 'CH069'; 'CH070';...
     'CH071'; 'CH072'; 'CH073'; 'CH074'; 'CH075'; 'CH076'; 'CH077'; 'CH078'; 'CH079'; 'CH080';...
     'CH081'; 'CH082'; 'CH083'; 'CH084'; 'CH085'; 'CH086'; 'CH087'; 'CH088'; 'CH089'; 'CH090';...
     'CH091'; 'CH092'; 'CH093'; 'CH094'; 'CH095'; 'CH096'; 'CH097'; 'CH098'; 'CH099'; 'CH100';...
     'CH101'; 'CH102'; 'CH103'; 'CH104'; 'CH105'; 'CH106'; 'CH107'; 'CH108'; 'CH109'; 'CH110';...
     'CH111'; 'CH112'; 'CH113'; 'CH114'; 'CH115'; 'CH116'; 'CH117'; 'CH118'; 'CH119'; 'CH120';...
     'CH121'; 'CH122'; 'CH123'; 'CH124'; 'CH125'; 'CH126'; 'CH127'; 'CH128'};

 
%% create headbox montages
XTP_HB_MONTAGES(1).name = 'Mobee 32 - Double Banana';
XTP_HB_MONTAGES(1).headbox_id = 1;
XTP_HB_MONTAGES(1).channelNames{1,1} = 'Fp1-F3';
XTP_HB_MONTAGES(1).coefficients(1,:) = [0 1 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{2,1} = 'F3-C3';
XTP_HB_MONTAGES(1).coefficients(2,:) = [0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{3,1} = 'C3-P3';
XTP_HB_MONTAGES(1).coefficients(3,:) = [0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{4,1} = 'P3-O1';
XTP_HB_MONTAGES(1).coefficients(4,:) = [0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{5,1} = 'Fp2-F4';
XTP_HB_MONTAGES(1).coefficients(5,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{6,1} = 'F4-C4';
XTP_HB_MONTAGES(1).coefficients(6,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{7,1} = 'C4-P4';
XTP_HB_MONTAGES(1).coefficients(7,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{8,1} = 'P4-O2';
XTP_HB_MONTAGES(1).coefficients(8,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{9,1} = 'Fp1-F7';
XTP_HB_MONTAGES(1).coefficients(9,:) = [0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{10,1} = 'F7-T3';
XTP_HB_MONTAGES(1).coefficients(10,:) = [0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{11,1} = 'T3-T5';
XTP_HB_MONTAGES(1).coefficients(11,:) = [0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{12,1} = 'T5-O1';
XTP_HB_MONTAGES(1).coefficients(12,:) = [0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{13,1} = 'Fp2-F8';
XTP_HB_MONTAGES(1).coefficients(13,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{14,1} = 'F8-T4';
XTP_HB_MONTAGES(1).coefficients(14,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{15,1} = 'T4-T6';
XTP_HB_MONTAGES(1).coefficients(15,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{16,1} = 'T6-O2';
XTP_HB_MONTAGES(1).coefficients(16,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{17,1} = 'Fz-Cz';
XTP_HB_MONTAGES(1).coefficients(17,:) = [0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(1).channelNames{18,1} = 'Cz-Pz';
XTP_HB_MONTAGES(1).coefficients(18,:) = [0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

XTP_HB_MONTAGES(2).name = '36 channel EMU Headbox/EMU36 - DB as prev';
XTP_HB_MONTAGES(2).headbox_id = 2;
XTP_HB_MONTAGES(2).channelNames{1,1} = 'Fp1-F3';
XTP_HB_MONTAGES(2).coefficients(1,:) = [0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{2,1} = 'F3-C3';
XTP_HB_MONTAGES(2).coefficients(2,:) = [0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{3,1} = 'C3-P3';
XTP_HB_MONTAGES(2).coefficients(3,:) = [0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{4,1} = 'P3-O1';
XTP_HB_MONTAGES(2).coefficients(4,:) = [0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{5,1} = 'Fp2-F4';
XTP_HB_MONTAGES(2).coefficients(5,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{6,1} = 'F4-C4';
XTP_HB_MONTAGES(2).coefficients(6,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{7,1} = 'C4-P4';
XTP_HB_MONTAGES(2).coefficients(7,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{8,1} = 'P4-O2';
XTP_HB_MONTAGES(2).coefficients(8,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{9,1} = 'Fp1-F7';
XTP_HB_MONTAGES(2).coefficients(9,:) = [0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{10,1} = 'F7-T3';
XTP_HB_MONTAGES(2).coefficients(10,:) = [0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{11,1} = 'T3-T5';
XTP_HB_MONTAGES(2).coefficients(11,:) = [0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{12,1} = 'T5-O1';
XTP_HB_MONTAGES(2).coefficients(12,:) = [0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{13,1} = 'Fp2-F8';
XTP_HB_MONTAGES(2).coefficients(13,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{14,1} = 'F8-T4';
XTP_HB_MONTAGES(2).coefficients(14,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{15,1} = 'T4-T6';
XTP_HB_MONTAGES(2).coefficients(15,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{16,1} = 'T6-O2';
XTP_HB_MONTAGES(2).coefficients(16,:) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{17,1} = 'Fz-Cz';
XTP_HB_MONTAGES(2).coefficients(17,:) = [0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
XTP_HB_MONTAGES(2).channelNames{18,1} = 'Cz-Pz';
XTP_HB_MONTAGES(2).coefficients(18,:) = [0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

XTP_HB_MONTAGES(3).name = 'MOBEE 32 Headbox/EK DB 12 Bipolar Montage';
XTP_HB_MONTAGES(3).headbox_id = 1;
XTP_HB_MONTAGES(3).channelNames{	1	,1} = 'FP1-F3';
XTP_HB_MONTAGES(3).channelNames{	2	,1} = 'F3-FC1';
XTP_HB_MONTAGES(3).channelNames{	3	,1} = 'FC1-C3';
XTP_HB_MONTAGES(3).channelNames{	4	,1} = 'C3-CP1';
XTP_HB_MONTAGES(3).channelNames{	5	,1} = 'CP1-P3';
XTP_HB_MONTAGES(3).channelNames{	6	,1} = 'P3-O1';
%XTP_HB_MONTAGES(3).channelNames{	7	,1} = 'A1-O1';
XTP_HB_MONTAGES(3).channelNames{	7	,1} = 'FP2-F4';
XTP_HB_MONTAGES(3).channelNames{	8	,1} = 'F4-FC2';
XTP_HB_MONTAGES(3).channelNames{	9	,1} = 'FC2-C4';
XTP_HB_MONTAGES(3).channelNames{	10	,1} = 'C4-CP2';
XTP_HB_MONTAGES(3).channelNames{	11	,1} = 'CP2-P4';
XTP_HB_MONTAGES(3).channelNames{	12	,1} = 'P4-O2';
%XTP_HB_MONTAGES(3).channelNames{	14	,1} = 'A2-O2';
XTP_HB_MONTAGES(3).channelNames{	13	,1} = 'FP1-AF7';
XTP_HB_MONTAGES(3).channelNames{	14	,1} = 'AF7-F7';
XTP_HB_MONTAGES(3).channelNames{	15	,1} = 'F7-FC5';
XTP_HB_MONTAGES(3).channelNames{	16	,1} = 'FC5-T3';
XTP_HB_MONTAGES(3).channelNames{	17	,1} = 'T3-CP5';
XTP_HB_MONTAGES(3).channelNames{	18	,1} = 'CP5-T5';
XTP_HB_MONTAGES(3).channelNames{	19	,1} = 'T5-O1';
%XTP_HB_MONTAGES(3).channelNames{	22	,1} = 'A1-O1';
XTP_HB_MONTAGES(3).channelNames{	20	,1} = 'FP2-AF8';
XTP_HB_MONTAGES(3).channelNames{	21	,1} = 'AF8-F8';
XTP_HB_MONTAGES(3).channelNames{	22	,1} = 'F8-FC6';
XTP_HB_MONTAGES(3).channelNames{	23	,1} = 'FC6-T4';
XTP_HB_MONTAGES(3).channelNames{	24	,1} = 'T4-CP6';
XTP_HB_MONTAGES(3).channelNames{	25	,1} = 'CP6-T6';
XTP_HB_MONTAGES(3).channelNames{	26	,1} = 'T6-O2';
%XTP_HB_MONTAGES(3).channelNames{	30	,1} = 'A2-O2';
XTP_HB_MONTAGES(3).channelNames{	27	,1} = 'FZ-CZ';
XTP_HB_MONTAGES(3).channelNames{	28	,1} = 'CZ-PZ';
XTP_HB_MONTAGES(3).coefficients(1,:) = [	0	1	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(2,:) = [	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(3,:) = [	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(4,:) = [	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(5,:) = [	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(6,:) = [	0	0	0	0	0	0	-1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(7,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(8,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(9,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	1	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(10,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	-1	0	0	];
XTP_HB_MONTAGES(3).coefficients(11,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	1	0	0	];
XTP_HB_MONTAGES(3).coefficients(12,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(13,:) = [	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(14,:) = [	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(15,:) = [	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(16,:) = [	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(17,:) = [	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(18,:) = [	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(19,:) = [	0	0	0	0	0	1	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(20,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(21,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(22,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(23,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(24,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(25,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(26,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(27,:) = [	0	0	0	0	0	0	0	0	0	0	0	1	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	];
XTP_HB_MONTAGES(3).coefficients(28,:) = [	0	0	0	0	0	0	0	0	0	0	0	0	1	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	];

XTP_HB_MONTAGES(4).name = 'Laureys EEG 19lead Headbox, Double Banana montage';
XTP_HB_MONTAGES(4).headbox_id = 3;
XTP_HB_MONTAGES(4).channelNames = {
    'Fp1-F7'
    'F7-T3'
    'T3-T5'
    'T5-O1'
    'Fp2-F8'
    'F8-T4'
    'T4-T6'
    'T6-O2'
    'Fp1-F3'
    'F3-C3'
    'C3-P3'
    'P3-O1'
    'Fp2-F4'
    'F4-C4'
    'C4-P4'
    'P4-O2'
    'Fz-Cz'
    'Cz-Pz'};

XTP_HB_MONTAGES(4).coefficients = [
     1     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     1     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     1     0     0     0     0    -1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0    -1     0
     0     1     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     1     0     0     0     0    -1     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0    -1     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0    -1
     1     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     1     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     1     0     0     0     0    -1     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0    -1     0
     0     1     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     1     0     0     0     0    -1     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0    -1     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0    -1
     0     0     0     0     1     0     0     0     0    -1     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     1     0     0     0     0    -1     0     0     0     0
];

XTP_HB_MONTAGES(5).name = 'MOBEE 32 HEADBOX LEFT Hemisphere';
XTP_HB_MONTAGES(5).headbox_id = 1;
XTP_HB_MONTAGES(5).channelNames{	1	,1} =     'FP1-F3';
XTP_HB_MONTAGES(5).channelNames{	2	,1} =     'F3-FC1';
XTP_HB_MONTAGES(5).channelNames{	3	,1} =     'C3-FC1';
XTP_HB_MONTAGES(5).channelNames{	4	,1} =     'C3-CP1';
XTP_HB_MONTAGES(5).channelNames{	5	,1} =     'P3-CP1';
XTP_HB_MONTAGES(5).channelNames{	6	,1} =     'FP1-AF7';
XTP_HB_MONTAGES(5).channelNames{	7	,1} =     'F7-AF7';
XTP_HB_MONTAGES(5).channelNames{	8	,1} =     'F7-FC5';
XTP_HB_MONTAGES(5).channelNames{	9	,1} =     'T3-FC5';
XTP_HB_MONTAGES(5).channelNames{	10	,1} =     'T3-CP5';
XTP_HB_MONTAGES(5).channelNames{	11	,1} =     'T5-CP5';
XTP_HB_MONTAGES(5).channelNames{	12	,1} =     'FZ-CZ';
XTP_HB_MONTAGES(5).channelNames{	13	,1} =     'CZ-PZ';
XTP_HB_MONTAGES(5).channelNames{	14	,1} =     'F3-F7';
XTP_HB_MONTAGES(5).channelNames{	15	,1} =     'FC1-FC5';
XTP_HB_MONTAGES(5).channelNames{	16	,1} =     'C3-T3';
XTP_HB_MONTAGES(5).channelNames{	17	,1} =     'CP1-CP5';
XTP_HB_MONTAGES(5).channelNames{	18	,1} =     'P3-T5';
XTP_HB_MONTAGES(5).coefficients(1,:) =  [     0     1     0     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(2,:) =  [     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(3,:) =  [     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(4,:) =  [     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(5,:) =  [     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(6,:) =  [     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(7,:) =  [     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(8,:) =  [     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(9,:) =  [     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(10,:) = [     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(11,:) = [     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(12,:) = [     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(13,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(14,:) = [     0     0    -1     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(15,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     1     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(16,:) = [     0     0     0    -1     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(17,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     1    0    0    0   ];
XTP_HB_MONTAGES(5).coefficients(18,:) = [     0     0     0     0     0    -1     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0    0   ];


XTP_HB_MONTAGES(6).name = 'MOBEE 32 HEADBOX RIGHT Hemisphere';
XTP_HB_MONTAGES(6).headbox_id = 1;
XTP_HB_MONTAGES(6).channelNames{	1	,1} =    'FP2-F4';
XTP_HB_MONTAGES(6).channelNames{	2	,1} =    'F4-FC2';
XTP_HB_MONTAGES(6).channelNames{	3	,1} =    'C4-FC2';
XTP_HB_MONTAGES(6).channelNames{	4	,1} =    'C4-CP2';
XTP_HB_MONTAGES(6).channelNames{	5	,1} =    'P4-CP2';
XTP_HB_MONTAGES(6).channelNames{	6	,1} =    'FP2-AF8';
XTP_HB_MONTAGES(6).channelNames{	7	,1} =    'F8-AF8';
XTP_HB_MONTAGES(6).channelNames{	8	,1} =    'F8-FC6';
XTP_HB_MONTAGES(6).channelNames{	9	,1} =    'T4-FC6';
XTP_HB_MONTAGES(6).channelNames{	10	,1} =    'T4-CP6';
XTP_HB_MONTAGES(6).channelNames{	11	,1} =    'T6-CP6';
XTP_HB_MONTAGES(6).channelNames{	12	,1} =    'FZ-CZ';
XTP_HB_MONTAGES(6).channelNames{	13	,1} =    'CZ-PZ';
XTP_HB_MONTAGES(6).channelNames{	14	,1} =    'F4-F8';
XTP_HB_MONTAGES(6).channelNames{	15	,1} =    'FC2-FC6';
XTP_HB_MONTAGES(6).channelNames{	16	,1} =    'C4-T4';
XTP_HB_MONTAGES(6).channelNames{	17	,1} =    'CP2-CP6';
XTP_HB_MONTAGES(6).channelNames{	18	,1} =    'P4-T6';
XTP_HB_MONTAGES(6).coefficients(1,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(2,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0    -1     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(3,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0    -1     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(4,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0    -1    0    0   ];
XTP_HB_MONTAGES(6).coefficients(5,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0    -1    0    0   ];
XTP_HB_MONTAGES(6).coefficients(6,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(7,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(8,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(9,:) =  [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(10,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(11,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0    -1     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(12,:) = [     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(13,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(14,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(15,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     1     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(16,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0     1     0     0     0     0     0     0     0     0     0     0     0    0    0   ];
XTP_HB_MONTAGES(6).coefficients(17,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     1    0    0   ];
XTP_HB_MONTAGES(6).coefficients(18,:) = [     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     1     0     0     0     0     0     0     0     0     0     0    0    0   ];

XTP_HB_MONTAGES(7).name = 'Mobee 32 Headbox, unipolar (vanilla) montage';
XTP_HB_MONTAGES(7).headbox_id = 1;
XTP_HB_MONTAGES(7).channelNames = {
'REF'
'FP1'
'F7'
'T3'
'A1'
'T5'
'O1'
'F3'
'C3'
'P3'
'FPZ'
'FZ'
'CZ'
'PZ'
'FP2'
'F8'
'T4'
'A2'
'T6'
'O2'
'F4'
'C4'
'P4'
'AF7'
'AF8'
'FC5'
'FC6'
'FC1'
'FC2'
'CP5'
'CP6'
'CP1'
'CP2'
'OSAT'
'PR' };
XTP_HB_MONTAGES(7).coefficients = eye(35);
     
XTP_HB_MONTAGES(8).name = '36 Channel EMU Headbox, unipolar (vanilla) montage';
XTP_HB_MONTAGES(8).headbox_id = 2;
XTP_HB_MONTAGES(8).channelNames = {
'AC1'
'AC2'
'REF'
'FP1'
'F7'
'T3'
'T5'
'O1'
'F3'
'C3'
'P3'
'FZ'
'CZ'
'PZ'
'F4'
'C4'
'P4'
'FP2'
'F8'
'T4'
'T6'
'O2'
'AC23'
'AC24'
'AC25'
'AC26'
'AC27'
'AC28'
'AC29'
'AC30'
'AC31'
'AC32'
'DC1'
'DC2'
'DC3'
'DC4' };
XTP_HB_MONTAGES(8).coefficients = eye(36);

XTP_HB_MONTAGES(9).name = 'Generic 19 lead headbox, unipolar (vanilla) montage';
XTP_HB_MONTAGES(9).headbox_id = 3;
XTP_HB_MONTAGES(9).channelNames = {
    'Fp1'
    'Fp2'
    'F7'
    'F3'
    'Fz'
    'F4'
    'F8'
    'T3'
    'C3'
    'Cz'
    'C4'
    'T4'
    'T5'
    'P3'
    'Pz'
    'P4'
    'T6'
    'O1'
    'O2' };
XTP_HB_MONTAGES(9).coefficients = eye(19);

XTP_HB_MONTAGES(10).name = 'Generic 19 lead headbox with Pz as reference';
XTP_HB_MONTAGES(10).headbox_id = 3;
XTP_HB_MONTAGES(10).channelNames = {
    'Fp1'
    'Fp2'
    'F7'
    'F3'
    'Fz'
    'F4'
    'F8'
    'T3'
    'C3'
    'Cz'
    'C4'
    'T4'
    'T5'
    'P3'
    'Pz'
    'P4'
    'T6'
    'O1'
    'O2' };
XTP_HB_MONTAGES(10).coefficients = [
         1     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0
     0     1     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0
     0     0     1     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0
     0     0     0     1     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     0
     0     0     0     0     1     0     0     0     0     0     0     0     0     0    -1     0     0     0     0
     0     0     0     0     0     1     0     0     0     0     0     0     0     0    -1     0     0     0     0
     0     0     0     0     0     0     1     0     0     0     0     0     0     0    -1     0     0     0     0
     0     0     0     0     0     0     0     1     0     0     0     0     0     0    -1     0     0     0     0
     0     0     0     0     0     0     0     0     1     0     0     0     0     0    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     1     0     0     0     0    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     1     0     0     0    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     1     0     0    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     1     0    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     1     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     1     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     1     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     0     1
    ];

XTP_HB_MONTAGES(11).name = 'DB montage for data exported using NDB Browser LBP International 10-20 view';
XTP_HB_MONTAGES(11).headbox_id = 4;
XTP_HB_MONTAGES(11).channelNames = {
        'Fp1-F3'
    'F3-C3'
    'C3-P3'
    'P3-O1'
    'Fp2-F4'
    'F4-C4'
    'C4-P4'
    'P4-O2'
    'Fp1-F7'
    'F7-T3'
    'T3-T5'
    'T5-O1'
    'Fp2-F8'
    'F8-T4'
    'T4-T6'
    'T6-O2'
    'Fz-Cz'
    'Cz-Pz'
};
XTP_HB_MONTAGES(11).coefficients = [
     1     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0    -1     0     0     1     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0    -1     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     1
     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0
     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0
];

XTP_HB_MONTAGES(12).name = 'Unipolar (vanilla) montage for data exported using NDB Browser LBP International 10-20 view';
XTP_HB_MONTAGES(12).headbox_id = 4;
XTP_HB_MONTAGES(12).channelNames = {
    'Fp1'
    'F7'
    'T3'
    'T5'
    'O1'
    'F3'
    'C3'
    'P3'
    'Fz'
    'Cz'
    'Pz'
    'Fp2'
    'F8'
    'T4'
    'T6'
    'O2' 
    'F4'
    'C4'
    'P4' };
XTP_HB_MONTAGES(12).coefficients = eye(19);

XTP_HB_MONTAGES(13).name = 'DB montage for EMU36 data exported using NDB Browser LBP International 10-20 view';
XTP_HB_MONTAGES(13).headbox_id = 5;
XTP_HB_MONTAGES(13).channelNames = {
        'Fp1-F3'
    'F3-C3'
    'C3-P3'
    'P3-O1'
    'Fp2-F4'
    'F4-C4'
    'C4-P4'
    'P4-O2'
    'Fp1-F7'
    'F7-T3'
    'T3-T5'
    'T5-O1'
    'Fp2-F8'
    'F8-T4'
    'T4-T6'
    'T6-O2'
    'Fz-Cz'
    'Cz-Pz'
};
XTP_HB_MONTAGES(13).coefficients = [
     1     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0    -1     0     0     1     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0    -1
     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1
     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0
    ];

XTP_HB_MONTAGES(14).name = 'Unipolar (vanilla) montage for EMU36 data exported using NDB Browser LBP International 10-20 view';
XTP_HB_MONTAGES(14).headbox_id = 5;
XTP_HB_MONTAGES(14).coefficients = eye(19);
XTP_HB_MONTAGES(14).channelNames = {
    'Fp1'
    'F7'
    'T3'
    'T5'
    'O1'
    'F3'
    'C3'
    'P3'
    'Fz'
    'Cz'
    'Pz'
    'F4'
    'C4'
    'P4'
    'Fp2'
    'F8'
    'T4'
    'T6'
    'O2'
};

XTP_HB_MONTAGES(15).name = 'EK DB12 montage for Mobee 32 data exported using NDB Browser, custom EK DB12 view';
XTP_HB_MONTAGES(15).headbox_id = 6;
XTP_HB_MONTAGES(15).channelNames = {
        'Fp1-F3'
    'F3-FC1'
    'FC1-C3'
    'C3-CP1'
    'CP1-P3'
    'P3-O1'
    'Fp2-F4'
    'F4-FC2'
    'FC2-C4'
    'C4-CP2'
    'CP2-P4'
    'P4-O2'
    'Fp1-AF7'
    'AF7-F7'
    'F7-FC5'
    'FC5-T3'
    'T3-CP5'
    'CP5-T5'
    'T5-O1'
    'Fp2-AF8'
    'AF8-F8'
    'F8-FC6'
    'FC6-T4'
    'T4-CP6'
    'CP6-T6'
    'T6-O2'
    'Fz-Cz'
    'Cz-Pz'
};
XTP_HB_MONTAGES(15).coefficients = [
1 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0
0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0
0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0
0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0
0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 -1 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 1 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 -1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0
0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0
0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0
0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0
0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0
0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
];  
% to get the above I typed fprintf(1, '%d %d %d...<one %d for each lead>\n', mtx')
% where mtx is the output from xtp_createMontage.
% note the transpose on the mtx is very important!

% #16
XTP_HB_MONTAGES(16).name = 'Unipolar (vanilla) montage for Mobee 32 data exported using NDB Browser, custom EK DB12 view';
XTP_HB_MONTAGES(16).headbox_id = 6;
XTP_HB_MONTAGES(16).channelNames = XTP_HEADBOXES(6).lead_list;
XTP_HB_MONTAGES(16).coefficients = eye(29);

% #17
XTP_HB_MONTAGES(17).name = 'Unipolar Mobee32 montage with all leads referenced to Pz';
XTP_HB_MONTAGES(17).headbox_id = 1;
XTP_HB_MONTAGES(17).channelNames = {
    'FP1-PZ'
    'F7-PZ'
    'T3-PZ'
    'T5-PZ'
    'O1-PZ'
    'FP2-PZ'
    'F8-PZ'
    'T4-PZ'
    'T6-PZ'
    'O2-PZ'
    'F3-PZ'
    'C3-PZ'
    'P3-PZ'
    'F4-PZ'
    'C4-PZ'
    'P4-PZ'
    'FZ-PZ'
    'CZ-PZ'
};
XTP_HB_MONTAGES(17).coefficients = [
 0 1 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 1 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 1 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 1 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 1 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 1 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 1 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ];

XTP_HB_MONTAGES(18).name = 'Mobee32 montage with hemispheric common reference (excludes midline leads)';
XTP_HB_MONTAGES(18).headbox_id = 1;
XTP_HB_MONTAGES(18).channelNames = {
    'Fp1'
    'F7'
    'T3'
    'T5'
    'O1'
    'Fp2'
    'F8'
    'T4'
    'T6'
    'O2'
    'F3'
    'C3'
    'P3'
    'F4'
    'C4'
    'P4'
};
XTP_HB_MONTAGES(18).coefficients = [
 0.000 0.875 -0.125 -0.125 0.000 -0.125 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 -0.125 0.875 -0.125 0.000 -0.125 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 -0.125 -0.125 0.875 0.000 -0.125 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 -0.125 -0.125 -0.125 0.000 0.875 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 -0.125 -0.125 -0.125 0.000 -0.125 0.875 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 -0.125 -0.125 -0.125 0.000 -0.125 -0.125 0.875 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 -0.125 -0.125 -0.125 0.000 -0.125 -0.125 -0.125 0.875 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 -0.125 -0.125 -0.125 0.000 -0.125 -0.125 -0.125 -0.125 0.875 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.875 -0.125 -0.125 0.000 -0.125 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 -0.125 0.875 -0.125 0.000 -0.125 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 -0.125 -0.125 0.875 0.000 -0.125 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 -0.125 -0.125 -0.125 0.000 0.875 -0.125 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 -0.125 -0.125 -0.125 0.000 -0.125 0.875 -0.125 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 -0.125 -0.125 -0.125 0.000 -0.125 -0.125 0.875 -0.125 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 -0.125 -0.125 -0.125 0.000 -0.125 -0.125 -0.125 0.875 -0.125 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 -0.125 -0.125 -0.125 0.000 -0.125 -0.125 -0.125 -0.125 0.875 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
];

%#19
XTP_HB_MONTAGES(19).name = 'Mobee32 montage with average common reference (includes midline leads)';
XTP_HB_MONTAGES(19).headbox_id = 1;
XTP_HB_MONTAGES(19).channelNames = {
    'Fp1'
    'F7'
    'T3'
    'T5'
    'O1'
    'F3'
    'C3'
    'P3'
    'Fz'
    'Cz'
    'Pz'
    'Fp2'
    'F8'
    'T4'
    'T6'
    'O2'
    'F4'
    'C4'
    'P4'
};
leadnums = [2 3 4 6 7 8 9 10 12 13 14 15 16 17 19 20 21 22 23]; % based on lead list in mobee32 headbox
cf = zeros(19,35);
cf(:,leadnums) = eye(19);   % each channel associated with one lead
cf(:,leadnums) = cf(:,leadnums)-(1/19); % subtract mean of the 19 leads
XTP_HB_MONTAGES(19).coefficients = cf;
clear cf leadnums
    
%#20
XTP_HB_MONTAGES(20).name = 'EMU 36 Pz Ref montage';
XTP_HB_MONTAGES(20).headbox_id = 2;
XTP_HB_MONTAGES(20).channelNames = {
    'FP1-PZ'
    'F7-PZ'
    'T3-PZ'
    'T5-PZ'
    'O1-PZ'
    'FP2-PZ'
    'F8-PZ'
    'T4-PZ'
    'T6-PZ'
    'O2-PZ'
    'F3-PZ'
    'C3-PZ'
    'P3-PZ'
    'F4-PZ'
    'C4-PZ'
    'P4-PZ'
    'FZ-PZ'
    'CZ-PZ'
};

XTP_HB_MONTAGES(20).coefficients = ...
    [0,0,0,1,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,1,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,1,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,1,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,1,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,1,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,1,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,1,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

%#21
XTP_HB_MONTAGES(21).name = 'Neonatal for EMU32';
XTP_HB_MONTAGES(21).headbox_id = 7;
XTP_HB_MONTAGES(21).channelNames = {'Fp1-C3';'C3-O1';'Fp1-T3';'T3-O1';'Fp2-C4';'C4-O2';'Fp2-T4';'T4-O2';'Fz-Cz';};
XTP_HB_MONTAGES(21).coefficients = ...
    [1,0,0,-1,0,0,0,0,0,0;0,0,-1,1,0,0,0,0,0,0;1,-1,0,0,0,0,0,0,0,0;0,1,-1,0,0,0,0,0,0,0;0,0,0,0,0,0,1,0,0,-1;0,0,0,0,0,0,0,0,-1,1;0,0,0,0,0,0,1,-1,0,0;0,0,0,0,0,0,0,1,-1,0;0,0,0,0,1,-1,0,0,0,0];

%#22
XTP_HB_MONTAGES(22).name = 'EMU40 bipolar';
XTP_HB_MONTAGES(22).headbox_id = 8;
XTP_HB_MONTAGES(22).channelNames = {'FPz-Fp1';'Fp1-F3';'F3-FC1';'FC1-C3';'C3-CP1';'CP1-P3';'FPz-Fp2';'Fp2-F4';'F4-FC2';'FC2-C4';'C4-CP2';'CP2-P4';'Fp1-AF7';'AF7-F7';'F7-FC5';'F1-FC1';'Fp2-AF8';'AF8-F8';'F8-FC6';'F2-FC2';'FC5-T3';'T3-CP5';'CP5-T5';'T5-PO7';'FC6-T4';'T4-CP6';'CP6-T6';'T6-PO8';'Fz-Cz';'Cz-Pz';'CPz-POz';'POz-Oz'};
XTP_HB_MONTAGES(22).coefficients = [-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;1,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0;0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0];

%#23
XTP_HB_MONTAGES(23).name = 'EMU40 bipolar + 4 occipital channels';
XTP_HB_MONTAGES(23).headbox_id = 8;
XTP_HB_MONTAGES(23).channelNames = {'FPz-Fp1';'Fp1-F3';'F3-FC1';'FC1-C3';'C3-CP1';'CP1-P3';'FPz-Fp2';'Fp2-F4';'F4-FC2';'FC2-C4';'C4-CP2';'CP2-P4';'Fp1-AF7';'AF7-F7';'F7-FC5';'F1-FC1';'Fp2-AF8';'AF8-F8';'F8-FC6';'F2-FC2';'FC5-T3';'T3-CP5';'CP5-T5';'T5-PO7';'FC6-T4';'T4-CP6';'CP6-T6';'T6-PO8';'Fz-Cz';'Cz-Pz';'CPz-POz';'POz-Oz';'PO7-O1';'P3-O1';'PO8-O2';'P4-O2'};
XTP_HB_MONTAGES(23).coefficients = [-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;1,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0;0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0;0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,-1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

%#24 for NK
XTP_HB_MONTAGES(24).name = 'Double Banana montage for NK ref A1<>A2 exports';
XTP_HB_MONTAGES(24).headbox_id = 11;
XTP_HB_MONTAGES(24).channelNames = {
    'Fp1-F7'
    'F7-T3'
    'T3-T5'
    'T5-O1'
    'Fp2-F8'
    'F8-T4'
    'T4-T6'
    'T6-O2'
    'Fp1-F3'
    'F3-C3'
    'C3-P3'
    'P3-O1'
    'Fp2-F4'
    'F4-C4'
    'C4-P4'
    'P4-O2'
    'Fz-Cz'
    'Cz-Pz'};

XTP_HB_MONTAGES(24).coefficients = [
     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     1     0     0     0     0     0     0     0    -1     0     0     0     0     0     0     0     0
     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     1     0     0     0     0     0     0     0    -1     0     0     0     0
     1     0     0     0     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0
     0     0     0     0     1     0     0     0     0     0     0     0    -1     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0
];

%#25 for NK EMU protocol
XTP_HB_MONTAGES(25).name = 'Double Banana montage for NK REF exports (EMU protocol)';
XTP_HB_MONTAGES(25).headbox_id = 12;
XTP_HB_MONTAGES(25).channelNames = {
    'Fp1-F7'
    'F7-T3'
    'T3-T5'
    'T5-O1'
    'Fp2-F8'
    'F8-T4'
    'T4-T6'
    'T6-O2'
    'Fp1-F3'
    'F3-C3'
    'C3-P3'
    'P3-O1'
    'Fp2-F4'
    'F4-C4'
    'C4-P4'
    'P4-O2'
    'Fz-Cz'
    'Cz-Pz'};

XTP_HB_MONTAGES(25).coefficients = [
     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     1     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     1     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     1     0    -1     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     1     0    -1     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0
     1     0     0     0     0     0     0    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0    -1     0     0     1     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     1     0     0     0     0     0     0    -1     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0    -1     0     0     1     0     0     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0     0
     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     1    -1     0     0
     ];

% #26 vanilla montage for NK ref A1<>A2 headbox
XTP_HB_MONTAGES(26).name = 'Unipolar montage for NK 20 channel export (headbox 11)';
XTP_HB_MONTAGES(26).headbox_id = 11;
XTP_HB_MONTAGES(26).channelNames = XTP_HEADBOXES(11).lead_list;
XTP_HB_MONTAGES(26).coefficients = diag(ones(length(XTP_HB_MONTAGES(26).channelNames), 1));

 
% #27 vanilla montage for NK EMU headbox
XTP_HB_MONTAGES(27).name = 'Unipolar montage for NK EMU export (headbox 12)';
XTP_HB_MONTAGES(27).headbox_id = 12;
XTP_HB_MONTAGES(27).channelNames = XTP_HEADBOXES(12).lead_list;
XTP_HB_MONTAGES(27).coefficients = diag(ones(length(XTP_HB_MONTAGES(27).channelNames), 1));

% #28 average common reference for NK ref A1<>A2 headbox
XTP_HB_MONTAGES(28).name = 'Average Common Reference for NK ref';
XTP_HB_MONTAGES(28).headbox_id = 11;
nhl = 19;   %number of leads on the head
XTP_HB_MONTAGES(28).channelNames = XTP_HEADBOXES(11).lead_list(1:nhl);
XTP_HB_MONTAGES(28).coefficients = [diag(ones(nhl,1))-(ones(nhl)/nhl) zeros(nhl,1)];

% #29 average common reference for NK EMU headbox
XTP_HB_MONTAGES(29).name = 'Average Common Reference for NK EMU headbox';
XTP_HB_MONTAGES(29).headbox_id = 12;
nhl = 23;   %number of leads on the head
XTP_HB_MONTAGES(29).channelNames = XTP_HEADBOXES(12).lead_list(1:nhl);
XTP_HB_MONTAGES(29).coefficients = [diag(ones(nhl,1))-(ones(nhl)/nhl) zeros(nhl,1)];

% #30 AvCommRef-1 (i.e. NOT including electrode of interest) for NK ref A1<>A2 headbox
XTP_HB_MONTAGES(30).name = 'Average Common Reference minus lead of interest for NK ref';
XTP_HB_MONTAGES(30).headbox_id = 11;
nhl = 19;   %number of leads on the head
XTP_HB_MONTAGES(30).channelNames = XTP_HEADBOXES(11).lead_list(1:nhl);
XTP_HB_MONTAGES(30).coefficients = [diag(ones(nhl,1))-(ones(nhl)/(nhl-1))+diag((ones(nhl,1)/(nhl-1))) zeros(nhl,1)];

% #31 AvCommRef-1 (i.e. NOT including electrode of interest) for NK EMU headbox
XTP_HB_MONTAGES(31).name = 'Average Common Reference minus lead of interest for NK EMU headbox';
XTP_HB_MONTAGES(31).headbox_id = 12;
nhl = 23;   %number of leads on the head
XTP_HB_MONTAGES(31).channelNames = XTP_HEADBOXES(12).lead_list(1:nhl);
XTP_HB_MONTAGES(31).coefficients = [diag(ones(nhl,1))-(ones(nhl)/(nhl-1))+diag((ones(nhl,1)/(nhl-1))) zeros(nhl,1)];

% #32 HemCommRef-1 (i.e. not including electrode of interest) for NK ref A1<>A2 headbox
XTP_HB_MONTAGES(32).name = 'Hemispheric Common Reference minus lead of interest for NK ref';
XTP_HB_MONTAGES(32).headbox_id = 11;
nhl = 19;   %number of active electrode leads on the head
XTP_HB_MONTAGES(32).channelNames = XTP_HEADBOXES(11).lead_list(1:nhl);
lhl = [1:4 9:12 17:19]; % lead numbers for left side
rhl = [5:8 13:16];
nlhl=length(lhl); nrhl=length(rhl); % number of leads on each side
leftHem = diag(ones(nlhl,1))-(ones(nlhl)/(nlhl-1))+diag((ones(nlhl,1)/(nlhl-1)));
rightHem = diag(ones(nrhl,1))-(ones(nrhl)/(nrhl-1))+diag((ones(nrhl,1)/(nrhl-1)));
XTP_HB_MONTAGES(32).coefficients = zeros(nhl, 20);
XTP_HB_MONTAGES(32).coefficients(lhl,lhl)= leftHem;
XTP_HB_MONTAGES(32).coefficients(rhl,rhl)= rightHem;
clear nhl lhl rhl nlhl rlhl leftHem rightHem

% #33 HemCommRef-1 (i.e. not including electrode of interest) for NK EMU headbox
XTP_HB_MONTAGES(33).name = 'Hemispheric Common Reference minus lead of interest for NK EMU headbox';
XTP_HB_MONTAGES(33).headbox_id = 12;
nhl = 23;   %number of leads on the head
XTP_HB_MONTAGES(33).channelNames = XTP_HEADBOXES(12).lead_list(1:nhl);
lhl = [1:10 21:23]; % lead numbers for left side
rhl = [11:20];
nlhl=length(lhl); nrhl=length(rhl); % number of leads on each side
leftHem = diag(ones(nlhl,1))-(ones(nlhl)/(nlhl-1))+diag((ones(nlhl,1)/(nlhl-1)));
rightHem = diag(ones(nrhl,1))-(ones(nrhl)/(nrhl-1))+diag((ones(nrhl,1)/(nrhl-1)));
XTP_HB_MONTAGES(33).coefficients = zeros(nhl, 25);
XTP_HB_MONTAGES(33).coefficients(lhl,lhl)= leftHem;
XTP_HB_MONTAGES(33).coefficients(rhl,rhl)= rightHem;
clear nhl lhl rhl nlhl rlhl leftHem rightHem

% #34 vanilla montage for NK 0v headbox
XTP_HB_MONTAGES(34).name = 'Unipolar montage for NK 0V export (headbox 13)';
XTP_HB_MONTAGES(34).headbox_id = 13;
XTP_HB_MONTAGES(34).channelNames = XTP_HEADBOXES(13).lead_list;
XTP_HB_MONTAGES(34).coefficients = diag(ones(length(XTP_HB_MONTAGES(34).channelNames), 1));

% #35 AvCommRef-1 (i.e. NOT including electrode of interest) for NK 0V export
XTP_HB_MONTAGES(35).name = 'Average Common Reference minus lead of interest for NK 0V headbox (13)';
XTP_HB_MONTAGES(35).headbox_id = 13;
nhl = 19;   %number of leads on the head (leads of interest)
XTP_HB_MONTAGES(35).channelNames = XTP_HEADBOXES(13).lead_list(1:nhl);
XTP_HB_MONTAGES(35).coefficients = [diag(ones(nhl,1))-(ones(nhl)/(nhl-1))+diag((ones(nhl,1)/(nhl-1))) zeros(nhl,length(XTP_HEADBOXES(13).lead_list)-nhl)];

% #36 vanilla montage for Natus 65535 headbox
XTP_HB_MONTAGES(36).name = 'Reference montage for Natus 128 channel (headbox 14)';
XTP_HB_MONTAGES(36).headbox_id = 14;
XTP_HB_MONTAGES(36).channelNames = XTP_HEADBOXES(14).lead_list;
XTP_HB_MONTAGES(36).coefficients = diag(ones(length(XTP_HB_MONTAGES(36).channelNames), 1));

% #37 bipolar montage for Natus 65535 headbox - all leads
XTP_HB_MONTAGES(37).name = 'Blind bipolar montage for Natus 128 channel (headbox 14)';
XTP_HB_MONTAGES(37).headbox_id = 14;
nLeads = length(XTP_HEADBOXES(14).lead_list);
posCoeffs = diag(ones(nLeads-1,1));
negCoeffs = [zeros(nLeads-1,1) posCoeffs(:,1:nLeads-1)]*(-1);
XTP_HB_MONTAGES(37).coefficients = [posCoeffs zeros(nLeads-1,1)]+negCoeffs;
leadA = XTP_HEADBOXES(14).lead_list(1:nLeads-1);
leadB = XTP_HEADBOXES(14).lead_list(2:nLeads);
minuses = cellstr(repmat('-', nLeads-1,1));
XTP_HB_MONTAGES(37).channelNames = cellstr(cell2mat([leadA minuses leadB]));

% #38 bipolar montage for Natus 65535 headbox - chans of interest for SVF05
XTP_HB_MONTAGES(38).name = 'Bipolar montage for SVF05 analysis';
XTP_HB_MONTAGES(38).headbox_id = 14;
posCoeff = [67 91 92 93 1 95 96 97 9 75 76 77 10 17 18 19 25 120 121 122 33 124 125 126 34 108 109 110 35 49 50 51];
negCoeff = [68 92 93 94 2 96 97 98 10 76 77 78 11 18 19 20 26 121 122 123 41 125 126 127 42 109 110 111 43 57 58 59];
XTP_HB_MONTAGES(38).coefficients = zeros(length(posCoeff), length(XTP_HEADBOXES(14).lead_list));
for chNum = 1:length(posCoeff)
    XTP_HB_MONTAGES(38).coefficients(chNum,[posCoeff(chNum) negCoeff(chNum)]) = [1 -1];
end
XTP_HB_MONTAGES(38).channelNames = {...
    'LF7-LF8', 'LDA1-LDA2', 'LDA2-LDA3', 'LDA3-LDA4', ...
    'LFG1-LFG2', 'LDH1-LDH2', 'LDH2-LDH3', 'LDH3-LDH4', ...
    'LFG9-LFG10', 'LAT1-LAT2', 'LAT2-LAT3', 'LAT3-LAT4', ...
    'LFG10-LFG11', 'LIFG17-LIFG18', 'LIFG18-LIFG19','LIFG19-LIFG20', ...
    'LIFG25-LIFG26', 'RDA1-RDA2', 'RDA2-RDA3', 'RDA3-RDA4', ...
    'LSTP33-LSTP41', 'RDH1-RDH2', 'RDH2-RDH3', 'RDH3-RDH4', ...
    'LSTG34-LSTG42', 'RAT1-RAT2', 'RAT2-RAT3', 'RAT3-RAT4', ...
    'LSTG35-LSTG43', 'LITP49-LITP57', 'LITG50-LITG58', 'LITG51-LITG59' ...
    };
% #39: AVERAGE COMMON REF
[~, ~, ~] = xtp_createMontage(14, 'avgRef', true, 'name', 'Average Common Ref Montage for Natus (128 channels in average!)');


%v6.0s - add plotLocations to all the HB_MONTAGES that have plotLocations
%identified for their channels
for montageNum = 1:length(XTP_HB_MONTAGES)
    headbox = XTP_HEADBOXES(XTP_HB_MONTAGES(montageNum).headbox_id);
    % fprintf('montage %d, headbox %d\n', montageNum, XTP_HB_MONTAGES(montageNum).headbox_id);
    if ~isempty(headbox.plotLocations)
        chCoeffs = XTP_HB_MONTAGES(montageNum).coefficients;
        % fprintf('\tplotLocations %d,\tchCoeffs %d\n', size(headbox.plotLocations,1), size(chCoeffs,2));
        rawChannelLocs = abs(chCoeffs) * headbox.plotLocations;
        XTP_HB_MONTAGES(montageNum).plotLocations = rawChannelLocs ./ repmat(sum(abs(chCoeffs), 2),1,2);
    end
end

%% create coherency pairs
XTP_COHERENCY_PAIRS(1).name = 'Double Banana + Ipsilateral Coronal Pairings';
XTP_COHERENCY_PAIRS(1).headbox_id = 1;
XTP_COHERENCY_PAIRS(1).HBmontageID = 7;
XTP_COHERENCY_PAIRS(1).pairs = [...
     2     8;
     8     9;
     9    10;
    10     7;
    15    21;
    21    22;
    22    23;
    23    20;
     2     3;
     3     4;
     4     6;
     6     7;
    15    16;
    16    17;
    17    19;
    19    20;
    12    13;
    13    14;
     8     3;
     9     4;
    10     6;
    21    16;
    22    17;
    23    19];
XTP_COHERENCY_PAIRS(2).name = 'Double Banana + Ipsilateral Coronal Pairings (EMU)';
XTP_COHERENCY_PAIRS(2).headbox_id = 2;
XTP_COHERENCY_PAIRS(2).HBmontageID = 8;
XTP_COHERENCY_PAIRS(2).pairs = [...
    4   9
    9   10
    10  11
    11  8
    18  15
    15  16
    16  17
    17  22
    4   5
    5   6
    6   7
    7   8
    18  19
    19  20
    20  21
    21  22
    12  13
    13  14
    9   5
    10  6
    11  7
    15  19
    16  20
    17  21];

XTP_COHERENCY_PAIRS(3).name = 'Mobee 32 Headbox/EK DB 12 + Ipsilateral Coronal Pairings';
XTP_COHERENCY_PAIRS(3).headbox_id = 1;
XTP_COHERENCY_PAIRS(3).HBmontageID = 7;
XTP_COHERENCY_PAIRS(3).pairs = [...
     2     8
     8    28
     9    28
     9    32
    10    32
     5    10
     5     7
    15    21
    21    29
    22    29
    22    33
    23    33
    18    23
    18    20
     2    24
     3    24
     3    26
     4    26
     4    30
     6    30
     5     6
     5     7
    15    25
    16    25
    16    27
    17    27
    17    31
    19    31
    18    19
    18    20
    12    13
    13    14
    8      3
    28    26
    9      4
    32    30
    10     6
    21    16
    29    27
    22    17
    33    31
    23    19
    ];
%Coherency Pairs
XTP_COHERENCY_PAIRS(4).name = 'Mobee 32 Headbox, Hemisphere Coherency Pairs';
XTP_COHERENCY_PAIRS(4).headbox_id = 1;
XTP_COHERENCY_PAIRS(4).HBmontageID = 7;
XTP_COHERENCY_PAIRS(4).pairs = [...
     2    14
     3     4
     4     5
     9    10
    10    11
    ];

XTP_COHERENCY_PAIRS(5).name = 'Mobee 32 Headbox, DB montage, independent channels';
XTP_COHERENCY_PAIRS(5).headbox_id = 1;
XTP_COHERENCY_PAIRS(5).HBmontageID = 1;
XTP_COHERENCY_PAIRS(5).pairs = [...
	 2    10
     3    11
     6    14
     7    15
     1     5
     9    13
     2     6
    10    14
     3     7
    11    15
     4     8
    12    16];

XTP_COHERENCY_PAIRS(6).name = 'EMU36 Headbox, DB montage, independent channels';
XTP_COHERENCY_PAIRS(6).headbox_id = 2;
XTP_COHERENCY_PAIRS(6).HBmontageID = 2;
XTP_COHERENCY_PAIRS(6).pairs = [...
     2    10
     3    11
     6    14
     7    15
     1     5
     9    13
     2     6
    10    14
     3     7
    11    15
     4     8
    12    16];

XTP_COHERENCY_PAIRS(7).name = 'Mobee32 Headbox/Pz ref montage, LBP and ipsilateral & contralateral coronal pairs';
XTP_COHERENCY_PAIRS(7).headbox_id = 1;
XTP_COHERENCY_PAIRS(7).HBmontageID = 17;
XTP_COHERENCY_PAIRS(7).pairs = [...
     1    11
    11    12
    12    13
    13     5
     6    14
    14    15
    15    16
    16    10
     1     2
     2     3
     3     4
     4     5
     6     7
     7     8
     8     9
     9    10
    17    18
    11     2
    12     3
    13     4
    14     7
    15     8
    16     9
    1      6
    11     14
    12     15
    13     16
    5      10
    2      7
    3      8
    4      9
];

XTP_COHERENCY_PAIRS(8).name = 'Mobee32 Headbox/hemispheric average ref montage, LBP with ipsilateral coronal pairs';
XTP_COHERENCY_PAIRS(8).headbox_id = 1;
XTP_COHERENCY_PAIRS(8).HBmontageID = 18;
XTP_COHERENCY_PAIRS(8).pairs = [...
     1    11
    11    12
    12    13
    13     5
     6    14
    14    15
    15    16
    16    10
     1     2
     2     3
     3     4
     4     5
     6     7
     7     8
     8     9
     9    10
    11     2
    12     3
    13     4
    14     7
    15     8
    16     9
];

XTP_COHERENCY_PAIRS(9).name = 'Mobee32 Headbox/average common ref montage, LBP with ipsilateral coronal pairs (includes Fz,Cz,Pz)';
XTP_COHERENCY_PAIRS(9).headbox_id = 1;
XTP_COHERENCY_PAIRS(9).HBmontageID = 19;
XTP_COHERENCY_PAIRS(9).pairs = [...
     1  2
     2  3
     3  4
     4  5
     1  6
     6  7
     7  8
     8  5
     6  2
     7  3
     8  4
     9  10
     12 13
     13 14
     14 15
     15 16
     12 17
     17 18
     18 19
     19 16
     17 13
     18 14
     19 15
     10 11
];

XTP_COHERENCY_PAIRS(10).name = 'Mobee32, Average Common Ref montage, Interhemispheric pairs';
XTP_COHERENCY_PAIRS(10).headbox_id = 1;
XTP_COHERENCY_PAIRS(10).HBmontageID = 19;
XTP_COHERENCY_PAIRS(10).pairs = [...
	 1    12
     2    13
     6    17
     3    14
     7    18
     4    15
     8    19
     5    16
];

XTP_COHERENCY_PAIRS(11).name = 'EMU36 Headbox/Pz ref montage, LBP and ipsilateral & contralateral coronal pairs';
XTP_COHERENCY_PAIRS(11).headbox_id = 2;
XTP_COHERENCY_PAIRS(11).HBmontageID = 20;
XTP_COHERENCY_PAIRS(11).pairs = [...
     1    11
    11    12
    12    13
    13     5
     6    14
    14    15
    15    16
    16    10
     1     2
     2     3
     3     4
     4     5
     6     7
     7     8
     8     9
     9    10
    17    18
    11     2
    12     3
    13     4
    14     7
    15     8
    16     9
    1      6
    11     14
    12     15
    13     16
    5      10
    2      7
    3      8
    4      9
];

XTP_COHERENCY_PAIRS(12).name = 'Mobee32/EK DB12 montage, inter- and intra-hemispheric channel pairs';
XTP_COHERENCY_PAIRS(12).headbox_id = 1;
XTP_COHERENCY_PAIRS(12).HBmontageID = 3;
XTP_COHERENCY_PAIRS(12).pairs = [...
    13    20
    14    21
    15    22
    16    23
    17    24
    18    25
    19    26
     1     7
     2     8
     3     9
     4    10
     5    11
     6    12
    15     2
    22     8
    16     3
    23     9
    17     4
    24    10
    18     5
    25    11
    ];

XTP_COHERENCY_PAIRS(13).name = 'Independent channel pairs for DB montage of Laureys Generic 19lead EEG';
XTP_COHERENCY_PAIRS(13).headbox_id = 3;
XTP_COHERENCY_PAIRS(13).HBmontageID = 4;
XTP_COHERENCY_PAIRS(13).pairs = [...
    10     2
    11     3
    14     6
    15     7
     9    13
     1     5
    10    14
     2     6
    11    15
     3     7
    12    16
     4     8
];

XTP_COHERENCY_PAIRS(14).name = 'Mobee32/EK DB12 montage, inter- and intra-hemispheric channel pairs (extracted by browser)';
XTP_COHERENCY_PAIRS(14).headbox_id = 1;
XTP_COHERENCY_PAIRS(14).HBmontageID = 15;
XTP_COHERENCY_PAIRS(14).pairs = [...
    13    20
    14    21
    15    22
    16    23
    17    24
    18    25
    19    26
     1     7
     2     8
     3     9
     4    10
     5    11
     6    12
    15     2
    22     8
    16     3
    23     9
    17     4
    24    10
    18     5
    25    11
    ];
XTP_COHERENCY_PAIRS(15).name = 'Mobee 32 Headbox, DB montage, A/P independent channels';
XTP_COHERENCY_PAIRS(15).headbox_id = 1;
XTP_COHERENCY_PAIRS(15).HBmontageID = 1;
XTP_COHERENCY_PAIRS(15).pairs = [...
     9    12
     1     4
    13    16
     5     8
     9    11
    10    12
     1     3
     2     4
    13    15
    14    16
     5     7
     6     8
];
XTP_COHERENCY_PAIRS(16).name = 'EMU36 Headbox, DB montage, A/P independent channels';
XTP_COHERENCY_PAIRS(16).headbox_id = 2;
XTP_COHERENCY_PAIRS(16).HBmontageID = 2;
XTP_COHERENCY_PAIRS(16).pairs = [...
     9    12
     1     4
    13    16
     5     8
     9    11
    10    12
     1     3
     2     4
    13    15
    14    16
     5     7
     6     8
];

XTP_COHERENCY_PAIRS(17).name = 'Mobee32/EK DB 12 longitudinal cohpairs';
XTP_COHERENCY_PAIRS(17).headbox_id = 1;
XTP_COHERENCY_PAIRS(17).HBmontageID = 3;
XTP_COHERENCY_PAIRS(17).pairs = [...
    13    19
    20    26
     1     6
     7    12
    15    18
    22    25
     2     5
     8    11
    15    17
    22    24
     2     4
     8    10
    16    18
    23    25
     3     5
     9    11
    17    19
    24    26
     4     6
    10    12
];
XTP_COHERENCY_PAIRS(18).name = 'Mobee32 - 6 medial coherence pairs';
XTP_COHERENCY_PAIRS(18).headbox_id = 1;
XTP_COHERENCY_PAIRS(18).HBmontageID = 1;
XTP_COHERENCY_PAIRS(18).pairs = [...
2   17
6   17
3   18
7   18
2    6
3    7
];
%#19
XTP_COHERENCY_PAIRS(19).name = 'EMU40 inTERhemispheric Channel Pairs';
XTP_COHERENCY_PAIRS(19).headbox_id = 8;
XTP_COHERENCY_PAIRS(19).HBmontageID = 23;
XTP_COHERENCY_PAIRS(19).pairs = [...
     2     8
     3     9
     4    10
     5    11
     6    12
    34    36
    13    17
    14    18
    15    19
    16    20
    21    25
    22    26
    23    27
    24    28
    33    35
    ];
%#20
XTP_COHERENCY_PAIRS(20).name = 'EMU40 inTRAhemispheric Channel Pairs';
XTP_COHERENCY_PAIRS(20).headbox_id = 8;
XTP_COHERENCY_PAIRS(20).HBmontageID = 23;
XTP_COHERENCY_PAIRS(20).pairs = [...
     2    14
     8    18
     3    15
     9    19
     4    21
    10    25
     5    22
    11    26
     6    23
    12    27
    34    24
    36    28
    ];

%#20
XTP_COHERENCY_PAIRS(21).name = 'DD test HD/AST Channel Pairs';
XTP_COHERENCY_PAIRS(21).headbox_id = 14;
XTP_COHERENCY_PAIRS(21).HBmontageID = 36;
XTP_COHERENCY_PAIRS(21).pairs = [...
    35  19  % LDH/LAT
    36  20
    37  21
    38  22
    39  51  % RDH/RAT
    40  52
    41  53
    42  54
    ];
%% conversion factors
XTP_CONVERSION_FACTORS.units = {
    'mV'
    'uV'
    };

XTP_CONVERSION_FACTORS.factors = [  % columns represent from units, rows represent to units.
    1       1000            %e.g. to go from mV to uV you must multiply by 1000
    0.001   1               %e.g. to go from uV to mV you must multiply by 0.001
    ];

%% plot locations. 
% Each channel is a field of this structure. bipolar channels are
% represented as CH1CH2, with no - sign in between (e.g. FP1F3)

scale = 0.8;

% individual leads
XTP_PLOT_LOCATIONS = cell2struct(mat2cell(XTP_HEADBOXES(1).plotLocations*scale,ones(35,1),2),XTP_HEADBOXES(1).lead_list,1);

% bipolar channels
for ch = 1:18
    lead1 = XTP_HB_MONTAGES(1).coefficients(ch,:)==1;
    lead2 = XTP_HB_MONTAGES(1).coefficients(ch,:)==-1;
    chLoc = mean([XTP_HEADBOXES(1).plotLocations(lead1,:); XTP_HEADBOXES(1).plotLocations(lead2,:)],1);
    chName = strrep(XTP_HB_MONTAGES(1).channelNames{ch},'-','');
    XTP_PLOT_LOCATIONS.(upper(chName)) = scale*chLoc;
end
clear lead1 lead2 chLoc chName
end