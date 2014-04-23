function [SE IE DE LEV_DIST] = Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

	hypoF = fopen(hypothesis);
	line = fgetl(hypoF);
	hypoSents = {};
	c = 1;
	while line ~= -1
		line = strsplit(' ', line);
		line = line(3:end);
		hypoSents{c} = line;
		line = fgetl(hypoF);
		c = c + 1;
	end
	fclose(hypoF);
	DD = dir([annotation_dir, filesep, '*', 'txt']);
	annotSents = {};
	for iFile = 1:length(DD)
		if ~isempty(findstr(DD(iFile).name, 'unkn'))

			lines = textread([annotation_dir, filesep, DD(iFile).name], '%s','delimiter','\n');
			line = strsplit(' ', lines{1});
			line = line(3:end);
			index = str2num(char(regexp(DD(iFile).name, '\d{1,2}', 'match')));
			annotSents{index} = line;
		end
	end

	SE = 0;
	IE = 0;
	DE = 0;
	refWords = 0;
	for i =1:length(hypoSents)
		hypoSent = hypoSents{i};
		annotSent = annotSents{i};
		refWords = refWords + length(annotSent);
		[S I D] = levenshteinDistance(hypoSent, annotSent);
		SE = SE + S;
		IE = IE + I;
		DE = DE + D;
	end
	SE = SE/refWords;
	IE = IE/refWords;
	DE = DE/refWords;
	LEV_DIST = SE + IE + DE;





	function [SE IE DE] = levenshteinDistance(hypoSent,annotSent)
		annotSent = [' ' annotSent]; %Add extra word to help with indices
		hypoSent = [' ' hypoSent];   %Add extra word to help with indices
		n = length(annotSent);
		m = length(hypoSent);
		R = zeros(n,m);
		B = zeros(n,m);
		R(1,:) = Inf;
		R(:,1) = Inf;
		R(1,1) = 0;
		for i = 2:n
			for j=2:m
	
				del = R(i-1, j) + 1;
				sub = R(i-1, j-1) + (~strcmp(hypoSent(j), annotSent(i)));
				ins = R(i,j-1) + 1;
				R(i,j) = min([del;sub;ins]);
				if R(i,j) == del 
					B(i,j) = 1;  %1 = 'up'
				elseif R(i,j) == ins 
					B(i,j) = 2;   %2 = 'left'
				else
					B(i,j) = 3;   %3 = 'up-left'
				end
			end
		end

		SE = 0;
		IE = 0;
		DE = 0;
		i = n;
		j = m;
		while (i>1 & j>1)
			if (B(i,j) == 1)
				i = i - 1;
				DE = DE + 1;
			elseif (B(i,j) == 2)
				j = j - 1;
				IE = IE + 1;
			elseif (B(i,j) == 3)
				SE = SE + (~strcmp(hypoSent(j), annotSent(i)));
				i = i - 1;
				j = j - 1;
			end
		end
	end

end
