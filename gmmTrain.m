function gmms = gmmTrain( dir_train, max_iter, epsilon, M)
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%	
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture\



	
DD = dir( [ dir_train] );
gmms = {};
for iSpeaker = 3:length(DD)
	gmm = struct();
	speakerDir = fullfile(dir_train, DD(iSpeaker).name);
	gmm.name = DD(iSpeaker).name;
	DDSpeaker = dir([speakerDir, filesep, '*', 'mfcc']);

	%%Get data
	X = [];
	for iFile = 1:length(DDSpeaker);
		temp = load(fullfile(speakerDir, DDSpeaker(iFile).name), 'mfcc');
		X = [X ; temp];
	end


	%%Initialize Theta
	wM = ones(M,1).*(1/M);
	r = ceil(rand(M,1).*(length(X)-1)); %to ensure we don't get 0 or anything greater than M
	uM = X(r,:); %Initial means are M random vectors from the data of dimension d (14)
	%Since sigmaM is a diagonal matrix we initialize it to a vector with all 1s of length d(14) to represent a diagonal Identity matrix;
	
	sigmaM = ones(M, length(uM(1,:)));
	i = 0;
	prev_L = -Inf;
	improvement = Inf;
	while (i <= max_iter && improvement >= epsilon)
		[wM, uM, sigmaM, L] = eMStep(X, wM, uM, sigmaM);
		improvement = abs(sum(log(L)) - prev_L);
		prev_L = sum(log(L));
		i = i + 1;
	end

	gmm.weights = wM;
	gmm.means = uM;
	gmm.cov = sigmaM;
	gmms{iSpeaker - 2} = gmm;
	
end

end

% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------
function [wM, uM, sigmaM, L ] = eMStep(X, wM, uM, sigmaM)
	% E step
	[M,d] = size(uM);
	bMwM = [];
	pm = [];
	for i = 1:M
		uMI = repmat(uM(i,:), length(X), 1);
		sigmaMI = repmat(sigmaM(i,:), length(X), 1);
		b = ((exp(-0.5.*sum( ( (X - uMI).^2 )./sigmaMI, 2)))./(((2*pi)^(d/2)).*((prod(sigmaM(i,:)).^0.5))));
		bMwM(i,:) = b.*wM(i);
	end

	L = sum(bMwM);
	denom = repmat(sum(bMwM),M,1);
	pm = bMwM./denom;
	% M step
	wM = sum(pm,2)./length(X);
	temp = repmat(sum(pm,2), 1, d);
	uM = (pm*X)./temp;
	sigmaM = ((pm*(X.^2))./temp) - (uM.^2);



end





