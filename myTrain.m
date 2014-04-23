addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.7'))
dir_train = '/u/cs401/speechdata/Training';
DD = dir( [dir_train] );
data = struct();
for iSpeaker = 3:length(DD)
	speakerDir = fullfile(dir_train, DD(iSpeaker).name);
	DDSpeakerPhn = dir([speakerDir, filesep, '*', 'phn']);
	DDSpeakerMfcc = dir([speakerDir, filesep, '*', 'mfcc']);
	for iFile = 1:length(DDSpeakerPhn)
		mfccData = load(fullfile(speakerDir, DDSpeakerMfcc(iFile).name), 'mfcc');
		PhnFile  = fopen(fullfile(speakerDir, DDSpeakerPhn(iFile).name) );
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
			
			if (isfield(data, phoneme))
				data.(phoneme).seq = data.(phoneme).seq + 1;
				data.(phoneme).dataMatrix{data.(phoneme).seq} = mfccData(sIndex:eIndex, :)';
			else
				data.(phoneme) = struct();
				data.(phoneme).seq = 1;
				data.(phoneme).dataMatrix{1} = mfccData(sIndex:eIndex, :)';
			end		
			line = fgetl(PhnFile);

		end	
		fclose(PhnFile);
	
	end
end

%Training
phonemes = fieldnames(data);
for i = 1:length(phonemes)
	phoneme = char(phonemes(i));
	dataMat = data.(phoneme).dataMatrix;
	[n,m] = size(dataMat);
	n = ceil(n/3);
	dataMat = dataMat(1:n,:); %%Get only half the training data
	Hmm = initHMM(dataMat, 8, 3);
	Hmm = trainHMM(Hmm, data.(phoneme).dataMatrix, 6);
	data.(phoneme).HMM = Hmm;
end
save('phonemeStructt3.mat', 'data');


