function[] = LEO(trtData,bbData,doQuEST,doDiag,doIdentity,outputFileName)
  
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
        s = QuESTimate(measEr')./2;
        [occ, Vnd] = executeLEO(bbData,s);
        output{1,2} = 'QuEST';
        output{2,2} = 'Occupancy';
        output{2,3} = 'Vnd';
        for subj = 1:length(bbData)
            output{subj+2,2} = num2str(occ(subj));
            output{subj+2,3} = num2str(Vnd(subj));
        end
    end

    if doDiag
        s = cov(measEr')./2;
        s = s.*eye(size(s));
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
        s = eye(size(s));
        [occ, Vnd] = executeLEO(bbData,s);
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
    Vnd = zeros(length(bbData),1);
    occ = zeros(length(bbData),1);
    for subject = 1:length(bbData)    
        
        P = polyfit(bbData(subject).baseline,bbData(subject).baseline-bbData(subject).block,1);
        Vnd_Lassen = -P(2)/P(1);
        occ_Lassen = P(1);
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
        options = optimset('MaxFunEvals',100000,'MaxIter',100000);
        params = fminsearch(@logLikelyHoodFcn,startParam,options,bbData(subject).baseline,bbData(subject).block,s);

        Vnd(subject)  = exp(params(1));
        a = params(2);
        occ(subject)  = exp(a)/(1+exp(a));
    end
end

            
function[l] = logLikelyHoodFcn(v,Vt_BL,Vt_block,S)
    
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
    
    
    