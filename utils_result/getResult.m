function o2 = getResult(o, fmin_i, emin_i, timemax, mMode)
% This function takes in a o struct, fmin_i, emin_i, timemax, mMode
% mMode   : mean = 0, default median = 1
% It extract  f, e, fmin, emin, t, and output a new o struct with sub-fields
%   f          f(iteration) - fmin
%   e          e(iteration) - emin
%   mf_iter    mean of f(iteration)
%   me_iter    mean of e(iteration)
%   ft         f(time) - fmin, time synchroznied by linear iterpolation
%   et         e(time) - emin, time synchronized by linear iterpolation
%   T          time stamps
%   mf_t       mean of f(time)
%   me_t       mean of e(time)
% If the subfiel e does not exist in struct o then no operation on e.
%% Input hanlding
if nargin < 5  mMode = 1; end
%% Does subfiel e exists in o ?
if isfield(o,'e')  hasE = 1;
else               hasE = 0;
end
%% Get curve subtracted from fmin emin
% on f
% Make sure fmin_i and emin_i is column vector
if size(fmin_i,2) > size(fmin_i,1) fmin_i = fmin_i'; end
% subtract all f in o from fmin_i for each trial
f = bsxfun(@minus,o.f,fmin_i);

% on e
if hasE == 1
% Make sure fmin_i and emin_i is column vector
if size(emin_i,2) > size(emin_i,1) emin_i = emin_i'; end
% subtract all e in o from emin_i for each trial
e = bsxfun(@minus,o.e,emin_i);
end
%% Get mean curve (on iteration), median is prefered
if mMode == 1 % median (default)
 mf_iter = median(f);
 if hasE == 1
   me_iter = median(e);
 end
elseif mMode == 0 % mean
  mf_iter = mean(f);
 if hasE == 1
   me_iter = mean(e);
 end
end
%% Get Liner Interpolation on time
% on f
[ft,T] = multiLinInterp(f,o.t,timemax);
% on e
 if hasE == 1
   et = multiLinInterp(e,o.t,timemax);
 end
%% Get mean curve (on time), median is prefered
if mMode == 1 % median
 mf_t = median(ft);
 if hasE == 1
   me_t = median(et);
 end
elseif mMode == 0 % mean
 mf_t = mean(ft);
 if hasE == 1
   me_t = mean(et);
 end
end
%% Ouput handling
o2.f       = f;
o2.mf_iter = mf_iter;
o2.t       = T;
o2.f_t     = ft;
o2.mf_t    = mf_t;
if hasE == 1
    o2.e       = e;
    o2.me_iter = me_iter;
    o2.e_t     = et;
    o2.me_t    = me_t;
end
end 

%% call liner iterpolation (Code written by Andersen Man Shun Ang)
%{
function [F,T] = multiLinInterp(f,t,timemax)
N = min(size(f));
if N ~= min(size(t)) || max(size(f)) ~= max(size(t))
 error('Inputs need to have same sizes'); 
end

for i = 1 : N
 [F(i,:),T] = linInterp(f(i,:),t(i,:),timemax);
end
end%EOF

% Lin interp
function [F,T] = linInterp(f,t,Tmax)
% Change (f,t) to (F,T), where f(t) has different uneven time index t
%                        while F(T) has fix interval between elements
% Tmax is the max time
% the interval is 0 : stepsize : Tmax, stepsize determined by Tmax

% turn f,t into row vectors
if size(f,1)>size(f,2)  f = f'; end
if size(t,1)>size(t,2)  t = t'; end

f =[f(1) f];
t =[0    t];

if Tmax <= 2
  stepsize = 0.001;   
else
  stepsize = 0.5;
end

numTimepioint = floor(Tmax/stepsize);

for k = 1 : numTimepioint
 tk = k*stepsize; % We want to compute value of error at time tk
 % Find in which interval of t tk belongs 
 ilow = max( find(t < tk) ); 
 ihig = min( find(t >= tk) ); 
 % Do linear extrapolation: tk in [t(ilow),t(ihig)] 
 if t(ilow) == t(ihig)  error('vector t should be strictly increasing');end
 % convex combination
 F(k) = ( (t(ihig)-tk)*f(ilow) + (tk-t(ilow))*f(ihig)) / (t(ihig) - t(ilow));  
 T(k) = tk;
end
end
%}

%% Our version
function [F, T] = linInterp(f, t, Tmax, fixed_time_points)
f = f(:)';
t = t(:)';

f = [f(1), f];
t = [0, t];

if nargin < 4
    stepsize = 0.001;
    T = 0:stepsize:Tmax;
else
    T = fixed_time_points;
end

last_valid_time = min(max(t), Tmax);
last_valid_idx = find(t <= last_valid_time, 1, 'last');

F = nan(size(T)); 

for k = 1 : length(T)
    tk = T(k);
    
    if tk > t(last_valid_idx)
        F(k) = f(last_valid_idx);
        continue;
    end
    
    ilow = max(1, sum(t <= tk)); 
    ihig = min(length(t), find(t >= tk, 1)); 
    
    if ilow == ihig
        F(k) = f(ilow);
    else
        if ilow >= 1 && ilow <= length(f) && ihig >= 1 && ihig <= length(f)
            weight = (tk - t(ilow)) / (t(ihig) - t(ilow));
            
            F(k) = (1 - weight) * f(ilow) + weight * f(ihig);
        else
            F(k) = f(min(max(1, ilow), length(f)));
        end
    end
end
end

function [F, T] = multiLinInterp(f, t, timemax)
N = size(f, 1); 
stepsize = 0.1;
T = 0:stepsize:timemax;
F = nan(N, length(T)); 

for i = 1 : N
    f_trial = f(i, :);
    t_trial = t(i, :);
    
    valid_f = ~isnan(f_trial);
    valid_t = ~isnan(t_trial);
    valid_indices = valid_f & valid_t;
    
    f_trial = f_trial(valid_indices);
    t_trial = t_trial(valid_indices);
    
    if any(diff(t_trial) <= 0)
        [t_trial, sort_idx] = unique(t_trial, 'sorted');
        f_trial = f_trial(sort_idx);
    end
    
    if ~isempty(f_trial) && ~isempty(t_trial)
        [F(i, :), ~] = linInterp(f_trial, t_trial, timemax, T);
    else
        F(i, :) = nan(1, length(T));
    end
end
end

