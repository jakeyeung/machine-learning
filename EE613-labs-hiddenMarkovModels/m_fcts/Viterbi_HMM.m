function q = Viterbi_HMM(Data, model)
% Viterbi path decoding (MAP estimate of best path) in HMM.
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


% %MPE estimate of best path (for comparison)
% H = computeGammaHMM(s(1), model);
% [~,q] = max(H);

nbData = size(Data,2);

for i=1:model.nbStates
	B(i,:) = gaussPDF(Data, model.Mu(:,i), model.Sigma(:,:,i)); %Emission probability
end
%Viterbi forward pass
DELTA(:,1) = model.StatesPriors .* B(:,1);
PSI(1:model.nbStates,1) = 0;
for t=2:nbData
	for i=1:model.nbStates
		[maxTmp, PSI(i,t)] = max(DELTA(:,t-1) .* model.Trans(:,i));
		DELTA(i,t) = maxTmp * B(i,t); 
	end
end
%Backtracking
q = [];
[~,q(nbData)] = max(DELTA(:,nbData));
for t=nbData-1:-1:1
	q(t) = PSI(q(t+1),t+1);
end