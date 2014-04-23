function [base,meanData,proj] = pca(data,k)

disp('start eigendecomposition');
[xdim,ndata] = size(data);
meanData = sum(data,2)/ndata;  % compute mean of data
data = data-repmat(meanData,1,ndata); % substract the mean from the data
covariance = data*data'/ndata;  % form the covariance matrix

[eigenVectors, eigenDiag] = eig(covariance);  %eigendecomposition
eigenDiag = diag(eigenDiag);


% Sort the eigenvectors by their corressponding eigenvalues
[dontUse,p] = sort(-eigenDiag); %Negative so we get the biggest values in front
eigenDiag = eigenDiag(p);
eigenVectors = eigenVectors(:,p);

% Only keep the top k eigenvectors
base = eigenVectors(:,1:k);

% project the data
proj = base'*data;
disp('end eigendecomposition');
