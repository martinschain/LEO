function[] = LEO(trtData,bbData,doQuEST,doDiag,doIdentity,outputFileName)
%% Performs LEO calculation.
% LEO(trtData,bbData,doQuEST,doDiag,doIdentity,outputFileName)
% Results are saved into a file in the folder where the baseline-block data
% is stored. 

% Input arguments: 
% 1. trtData:         Holds test-retest data
% 2. bbData:          Holds baseline-block data
% 3. doQuest:         1 if non-linear shrink should be performed, 0 otherwise
% 4. doDiag:          1 if Diagonal cov matrix should be performed, 0 otherwise
% 5. doIdentity       1 if Identity cov matrix should be performed, 0 otherwise
% 6. outputFileName:  String of characters defining output file name.

% trtData is a MATLAB structure with the following fields:
% trtData(j).test:    vector with test VT values for subj j
% trtData(j).retest:  vector with retest VT values for subj j
% trtData(j).ROIs:    cell array with ROI names (same for all subjects)

% bbData is a MATLAB  structure with the following fields:
% bbData(j).baseline: vector with baseline VT values for subj j
% bbData(j).block:    vector with block VT values for subj j
% bbData(j).ROIs:     cell array with ROI names (same for all subjects)

% These structures can be obtained from an excel file, using
% LEO_readFromExcel.m

    % Estimate the measured error (noise) using test-retest data.
    for subj = 1:length(trtData);
        measEr(:,subj) = trtData(subj).test-trtData(subj).retest; %#ok
    end

    if doQuEST
        if isempty(which('QuESTimate'))
            disp('QuESTimate.m is not located in matlab path.')
            disp('This file needs to be downloaded from the URL below before NL-shrink option can be executed')
            disp('http://www.econ.uzh.ch/en/people/faculty/wolf/publications.html#9')
            doQuEST = 0;
        end
    end

    if isempty(which('cell2csv')) && ismac
        disp('cell2csv.m is not found in your matlab path.')
        disp('cell2csv.m is used to write the results to a file.')
        disp('Please download cell2csv.m from Mathworks homepage.')
        disp('Results will be printed in Matlab prompt.')
    end


    output{1,1} = 'Subject';
    for subj = 1:length(bbData), output{subj+2,1} = ['Subject ' num2str(subj)]; end % Create leftmost column in
    
    if doQuEST
        s = QuESTimate(measEr')./2; % Obtain shrinked version of cov matrix
        [occ, Vnd] = executeLEO(bbData,s); % Run LEO
        output{1,2} = 'QuEST';
        output{2,2} = 'Occupancy';
        output{2,3} = 'Vnd';
        for subj = 1:length(bbData)
            output{subj+2,2} = num2str(occ(subj));
            output{subj+2,3} = num2str(Vnd(subj));
        end
    end

    if doDiag
        s = cov(measEr')./2; % Obtain diagonal version of cov matrix
        s = s.*eye(size(s)); % Run LEO
        [occ, Vnd] = executeLEO(bbData,s);
        output{1,2+2*doQuEST} = 'Diag';
        output{2,2+2*doQuEST} = 'Occupancy';
        output{2,3+2*doQuEST} = 'Vnd';
        for subj = 1:length(bbData)
            output{subj+2,2+2*doQuEST} = num2str(occ(subj));
            output{subj+2,3+2*doQuEST} = num2str(Vnd(subj));
        end
    end

    if doIdentity
        s = cov(measEr')./2;
        s = eye(size(s)); % Obtain an identity matrix of the right dimension
        [occ, Vnd] = executeLEO(bbData,s); % Run LEO
        output{1,2+2*doQuEST+2*doDiag} = 'Identity';
        output{2,2+2*doQuEST+2*doDiag} = 'Occupancy';
        output{2,3+2*doQuEST+2*doDiag} = 'Vnd';
        for subj = 1:length(bbData)
            output{subj+2,2+2*doQuEST+2*doDiag} = num2str(occ(subj));
            output{subj+2,3+2*doQuEST+2*doDiag} = num2str(Vnd(subj));
        end
    end
    
    % Always do a Lassen plot for completeness
    output{1,2+2*doQuEST+2*doDiag+2*doIdentity} = 'Lassen plot';
    output{2,2+2*doQuEST+2*doDiag+2*doIdentity} = 'Occupancy';
    output{2,3+2*doQuEST+2*doDiag+2*doIdentity} = 'Vnd';
    for subj = 1:length(bbData)
        P = polyfit(bbData(subj).baseline,bbData(subj).baseline-bbData(subj).block,1);
        Vnd = -P(2)/P(1);
        occ = P(1);
        output{subj+2,2+2*doQuEST+2*doDiag+2*doIdentity} = num2str(occ);
        output{subj+2,3+2*doQuEST+2*doDiag+2*doIdentity} = num2str(Vnd);
    end
        
    % Save the results
    [fpath,fname] =  fileparts(outputFileName);
    outputFileName = [fpath filesep fname '.txt'];
    if ~isempty(which('cell2csv')) && isunix
        cell2csv(outputFileName,output,'\t');
        disp(['Results saved in ' outputFileName])
    elseif ispc
        xlswrite(outputFileName,output)
        disp(['Results saved in ' outputFileName])
    else
        disp('Saving to file not supported on your system, results are printed in prompt:')
        output %#ok
    end
end

function[occ, Vnd] = executeLEO(bbData,s)
    Vnd = zeros(length(bbData),1); %Pre-allocated vector for Vnd
    occ = zeros(length(bbData),1); %Pre-allocated vector for occupancy 
    for subject = 1:length(bbData)
        
        % For each subject, do a Lassen plot to set start parameters
        P = polyfit(bbData(subject).baseline,bbData(subject).baseline-bbData(subject).block,1);
        Vnd_Lassen = -P(2)/P(1);
        occ_Lassen = P(1);
        
        % If Lassen plot has provided unrealistic values, hardcoded
        % starting parameters will be used (min(VT)/2 for Vnd, and 0.7 for occupancy) 
        if Vnd_Lassen > 0 && Vnd_Lassen < min(bbData(subject).baseline)
            startParam(1,1) = log(Vnd_Lassen);
        else
            startParam(1,1) = log(min(bbData(subject).baseline)/2);
        end
        if occ_Lassen > 0 && occ_Lassen < 1;
            startParam(1,2) = log(occ_Lassen/(1-occ_Lassen));
        else
            startParam(1,2) = log(0.7/(1-0.7)); 
        end
        
        % Maximize the log-likelihood function (or, minimize -l):
        % To enforce constraints (Vnd>0 & 0<occ<1, minimize over
        % log(Vnd) and logit(occ).
        options = optimset('MaxFunEvals',100000,'MaxIter',100000);
        params = fminsearch(@logLikeliHoodFcn,startParam,options,bbData(subject).baseline,bbData(subject).block,s);

        Vnd(subject)  = exp(params(1));
        a = params(2);
        occ(subject)  = exp(a)/(1+exp(a));
    end
end

            
function[l] = logLikeliHoodFcn(v,Vt_BL,Vt_block,S)
    
    Vnd = exp(v(1));    
    a = v(2);
    occ = exp(a)/(1+exp(a));
    
    VsPre = Vt_BL - Vnd;    
    a = Vt_block-Vnd;
    Vs = (VsPre + (1-occ)*a)/(1+(1-occ)^2);
    
    l = -(Vt_BL- Vnd - Vs)'*inv(S)*(Vt_BL-Vnd-Vs)...
         -(Vt_block - Vnd - Vs*(1-occ))'*inv(S)*(Vt_block - Vnd - Vs*(1-occ));

    l = -l; 
end
    
    
    