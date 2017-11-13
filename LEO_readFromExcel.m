function[Data] = LEO_readFromExcel(fileName,type)
% type is either "BB" or "TrT"

[nums,strngs] = xlsread(fileName);

if mod(size(nums,2),2) %Check if nbr of scans is an even number (each subj measured twice).
    error('Number of scans is uneven - error in input data')
end

nbrOfSubjs = size(nums,2)/2;

switch lower(type)
    case 'trt'
        for subj = 1:nbrOfSubjs
            Data(subj).test = nums(:,2*subj-1);
            Data(subj).retest = nums(:,2*subj);
            Data(subj).ROIs = strngs(3:end,1);
        end
        
    case 'bb'
        for subj = 1:nbrOfSubjs
            Data(subj).baseline = nums(:,2*subj-1);
            Data(subj).block = nums(:,2*subj);
            Data(subj).ROIs = strngs(3:end,1);
        end
end
        