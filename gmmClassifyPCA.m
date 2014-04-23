clear all;
gmms = gmmTrainPCA('/u/cs401/speechdata/Training/',10,0.001,8, 10)
testDir = '/u/cs401/speechdata/Testing';
DD = dir([testDir, filesep, '*', 'mfcc']);
for iFile = 1:length(DD);
	Xorig = load(fullfile(testDir, DD(iFile).name), 'mfcc');
	
	probSpeakers = [];
	for s = 1:length(gmms)
		speaker = gmms{s};
		wM = speaker.weights;
		uM = speaker.means;
		sigmaM = speaker.cov;

		basePCA = speaker.basePCA;
		meanPCA = speaker.meanPCA;
		[ndata, xdim] = size(Xorig);
		
		X = Xorig' - repmat(meanPCA,1,ndata);
		X = basePCA'*X;
		X = X';
		disp('Did PCA');

		[M,d] = size(uM);
		bMwM = [];
		for i = 1:M
			uMI = repmat(uM(i,:), length(X), 1);
			sigmaMI = repmat(sigmaM(i,:), length(X), 1);
			b = (exp(-0.5.*sum( ( (X - uMI).^2 )./sigmaMI, 2)))./(((2*pi)^(d/2)).*((prod(sigmaM(i,:)).^0.5)));
			bMwM(i,:) = b.*wM(i);
		end
		probSpeaker = sum(log(sum(bMwM)));
		probSpeakers = [probSpeakers probSpeaker];
	end	
	
	[sortedProb,sortingIndices] = sort(probSpeakers,'descend');
	topFive = [gmms{sortingIndices(1:5)}];
	
	temp = strsplit('.',DD(iFile).name);
	fName =char(strcat(temp(1),'.lik'));

	fId = fopen(fName,'w'); 

	for i = 1:length(topFive)
		fprintf(fId,'%s\n',topFive(i).name);
	end
	fclose(fId);
	
	
end
