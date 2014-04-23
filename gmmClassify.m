clear all;
gmms = gmmTrain('/u/cs401/speechdata/Training/',30,0.1,8) %Change this to effect parameters.
testDir = '/u/cs401/speechdata/Testing';
DD = dir([testDir, filesep, '*', 'mfcc']);
fTestOutput = fopen('testOutput.txt', 'w');
for iFile = 1:length(DD);
	X = load(fullfile(testDir, DD(iFile).name), 'mfcc');
	
	probSpeakers = [];
	for s = 1:length(gmms)
		speaker = gmms{s};
		wM = speaker.weights;
		uM = speaker.means;
		sigmaM = speaker.cov;

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
	top = [gmms{sortingIndices(1)}];
	temp = strsplit('.',DD(iFile).name);
	fName =char(strcat(temp(1),'.lik'));
	fId = fopen(fName,'w'); 
	fprintf(fTestOutput,'%s   %s\n', char(temp(1)),top(1).name);
	for i = 1:length(topFive)
		fprintf(fId,'%s\n',topFive(i).name);
	end
	fclose(fId);
end