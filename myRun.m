addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.7'))
load('phonemeStructt3.mat');
phonemeStruct = data; 
dir_test = '/u/cs401/speechdata/Testing/';

DDTestPhn = dir([dir_test, filesep, '*', 'phn']);
DDTestMfcc = dir([dir_test, filesep, '*', 'mfcc']);
correct = 0;
total = 0;
testOutputPhoneme = {};
c = 1;
for iFile = 1:length(DDTestPhn)
	PhnFile  = fopen(fullfile(dir_test, DDTestPhn(iFile).name) );
	mfccData = load(fullfile(dir_test, DDTestMfcc(iFile).name), 'mfcc');
	line = fgetl(PhnFile);
	maxIndex = size(mfccData,1);
	
	while line ~= -1
		line = strsplit(' ', line);
		sIndex = max(str2num(line{1})/128,1);
		eIndex = min(str2num(line{2})/128, maxIndex);
		phoneme = char(line{3});
		if strcmp(phoneme, 'ax-h') == 1
			  phoneme = 'asDASHh';
		elseif strcmp(phoneme, 'h#') == 1
			  phoneme = 'hSHARP';
		elseif strcmp(phoneme, '1') == 1
			  phoneme = 'PSTRESS';
		elseif strcmp(phoneme, '2') == 1
			  phoneme = 'SSTRESS';
		end
		
		phonemes = fieldnames(phonemeStruct);
		phonemeLogLik = [];
		for i=1:length(phonemes)
			data = mfccData(sIndex:eIndex, :)';
			phonemeTest = char(phonemes(i));
			HMM = phonemeStruct.(phonemeTest).HMM;
			phonemeLogLik = [phonemeLogLik ; loglikHMM(HMM, data)];
		end
		[sortedProb, sortingIndices] = sort(phonemeLogLik,'descend');
		if (strcmp(phonemes(sortingIndices(1)), phoneme)) == 1
			testOutputPhoneme{total+1} = strcat('Correct: predicted:  ', phonemes(sortingIndices(1)), '  actual:  ', phoneme) ;
			correct = correct + 1;
		else
			testOutputPhoneme{total+1} = strcat('Incorrect: predicted: ', phonemes(sortingIndices(1)), '  actual:  ', phoneme) ;
		end
		total = total + 1;
		line = fgetl(PhnFile);
				
	end	
	fclose(PhnFile);
	fprintf('here\n');
	
end
fName =char('myRunTestOutput.txt');
fId = fopen(fName,'w'); 
for i = 1:length(testOutputPhoneme)
	fprintf(fId,'%s\n', char(testOutputPhoneme{i}));
end
fclose(fId);
correct/total
