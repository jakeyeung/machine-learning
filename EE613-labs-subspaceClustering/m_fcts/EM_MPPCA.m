function [model, GAMMA2] = EM_MPPCA(Data, model)
% EM for mixture of probabilistic principal component analyzers (implementation based on 
% "Mixtures of Probabilistic Principal Component Analysers" by Michael E. Tipping and Christopher M. Bishop)
%
% Writing code takes time. Polishing it and making it available to others takes longer! 
% If some parts of the code were useful for your research of for a better understanding 
% of the algorithms, please reward the authors by citing the related publications, 
% and consider making your own research available in this way.
%
% @article{Calinon15,
%   author="Calinon, S.",
%   title="A Tutorial on Task-Parameterized Movement Learning and Retrieval",
%   journal="Intelligent Service Robotics",
%   year="2015"
% }
%
% Copyright (c) 2015 Idiap Research Institute, http://idiap.ch/
% Written by Sylvain Calinon, http://calinon.ch/
% 
% This file is part of PbDlib, http://www.idiap.ch/software/pbdlib/
% 
% PbDlib is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
% 
% PbDlib is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with PbDlib. If not, see <http://www.gnu.org/licenses/>.


%Parameters of the EM iterations
nbMinSteps = 5; %Minimum number of iterations allowed
nbMaxSteps = 100; %Maximum number of iterations allowed
maxDiffLL = 1E-4; %Likelihood increase threshold to stop the algorithm
nbData = size(Data,2);

diagRegularizationFactor = 1E-6; %Regularization term is optional, see Eq. (2.1.2) in doc/TechnicalReport.pdf

%Initialization of the MPPCA parameters from eigendecomposition
for i=1:model.nbStates
	model.o(i) = trace(model.Sigma(:,:,i)) / model.nbVar;
	[V,D] = eig(model.Sigma(:,:,i)-eye(model.nbVar)*model.o(i)); 
	[~,id] = sort(diag(D),'descend');
	V = V(:,id)*D(id,id).^.5;
	model.L(:,:,i) = V(:,1:model.nbFA);
end

%EM loop
for nbIter=1:nbMaxSteps
	fprintf('.');
	
	%E-step
	[Lik, GAMMA] = computeGamma(Data, model); %See 'computeGamma' function below
	GAMMA2 = GAMMA ./ repmat(sum(GAMMA,2),1,nbData);
	
	%M-step
	%Update Priors
	model.Priors = sum(GAMMA,2) / nbData;
	
	%Update Mu
	model.Mu = Data * GAMMA2';
	
	%Update factor analyser params
	for i=1:model.nbStates
		%Compute covariance
		DataTmp = Data - repmat(model.Mu(:,i),1,nbData);
		S(:,:,i) = DataTmp * diag(GAMMA2(i,:)) * DataTmp' + eye(model.nbVar) * diagRegularizationFactor;

		%Update M 
		M = eye(model.nbFA)*model.o(i) + model.L(:,:,i)' * model.L(:,:,i);
		%Update Lambda 
		Lnew =  S(:,:,i) * model.L(:,:,i) / (eye(model.nbFA)*model.o(i) + M \ model.L(:,:,i)' * S(:,:,i) * model.L(:,:,i));
		%Update of sigma^2 
		model.o(i) = trace(S(:,:,i) - S(:,:,i) * model.L(:,:,i) / M * Lnew') / model.nbVar;
		model.L(:,:,i) = Lnew;
		%Update Psi 
		model.P(:,:,i) = eye(model.nbVar) * model.o(i);
		
		%Reconstruct Sigma
		model.Sigma(:,:,i) = real(model.L(:,:,i) * model.L(:,:,i)' + model.P(:,:,i));
	end
	
	%Compute average log-likelihood
	LL(nbIter) = sum(log(sum(Lik,1))) / nbData;
	%Stop the algorithm if EM converged (small change of LL)
	if nbIter>nbMinSteps
		if LL(nbIter)-LL(nbIter-1)<maxDiffLL || nbIter==nbMaxSteps-1
			disp(['EM converged after ' num2str(nbIter) ' iterations.']);
			return;
		end
	end
end
disp(['The maximum number of ' num2str(nbMaxSteps) ' EM iterations has been reached.']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Lik, GAMMA] = computeGamma(Data, model)
Lik = zeros(model.nbStates,size(Data,2));
for i=1:model.nbStates
	Lik(i,:) = model.Priors(i) * gaussPDF(Data, model.Mu(:,i), model.Sigma(:,:,i));
end
GAMMA = Lik ./ repmat(sum(Lik,1)+realmin, model.nbStates, 1);
end
