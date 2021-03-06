function xhat = SDE_euler_demo(bigtheta)

% Fixed stepsize Euler-Maruyama scheme [1], to be used only with the demo routines
%
% uasge: xhat = SDE_euler_demo(bigtheta)
%
% IN:     bigtheta; complete vector of structural model parameters
% OUTPUT: xhat; the SDE approximated solution 
% 
% Definitions of the global variables: 
%-----------------------------------------------------------------------------------------------------------
%         global PROBLEM; the user defined name of the current problem/experiment/example etc. (e.g. 'mySDE')
%         global OWNTIME; vector containing the equispaced simulation times sorted in ascending order. 
%                It has starting simulation-time in first and ending simulation-time in last position. 
%                Thus OWNTIME(i) - OWNTIME(i-1) = h, where h is the fixed stepsize 
%                for the numerical intregration (i=2,3,...)
%         global NUMDEPVARS; the number of dependent variables, i.e. the SDE dimension
%         global NUMSIM; the number of desired simulations for the SDE numerical integration 
%         global XVARS; the predicted values for the SDE state variables
%         global SDETYPE; the SDE definition: must be 'Ito'
%         global DW; the stochastic Wiener increments dW with dW(1,:) = 0; 
%
% REFERENCE: [1] Kloeden, Platen and Schurz "Numerical solution of SDE through computer experiments", Springer-Verlag 2nd edition 1997

% Copyright (C) 2007, Umberto Picchini  
% umberto.picchini@biomatematica.it
% http://www.biomatematica.it/Pages/Picchini.html
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.



global PROBLEM OWNTIME NUMDEPVARS NUMSIM XVARS SDETYPE DW;

switch SDETYPE
    case 'Ito'
        ok = 1;
    otherwise
        error('The Euler-Maruyama scheme is defined only for Ito SDE');
end
        

N = length(OWNTIME);
handle = waitbar(0,'Computing trajectories...');

[t, xstart] = feval([PROBLEM, '_sdefile'],OWNTIME(1),[],'init',bigtheta);  % initial conditions

XVARS = zeros(N,NUMSIM*NUMDEPVARS);  % the predictions matrix
XVARS(1,:) = xstart([1:size(xstart,1)]' * ones(1,NUMSIM), :)'; % ugly but faster than XVARS(1,:) = repmat(xstart,1,NUMSIM);

for j=2:N
    waitbar((j-1)/(N-1));
    % t is inherited as the starting time for this interval
    x = XVARS(j-1, :);           % the value(s) of XVARS at the start of the interval
    h = OWNTIME(j)- t;           % the delta time (end - start) -> fixed size of the step .
    Winc = DW(j,:);  % the Wiener increment(s) dWj; (these are the SAME increments used for the true solution, see SDE_demo.m)
 
    [f,g] = feval([PROBLEM, '_sdefile'], t, x, [], bigtheta);     % the sdefile output
    
    XVARS(j , :) = x + f * h + g .* Winc ;  % the Euler-Maruyama scheme for Ito SDEs
    
    t = OWNTIME(j);    % now both t and j refer to the end-of-interval   
end

xhat = XVARS;
close(handle);
