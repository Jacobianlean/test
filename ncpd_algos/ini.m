function [U,V,W,timemax,itermax,inneritermax,stepmethod,modify,projchoose,epsilon,isStore,Ustore,Vstore,Wstore] = ini(opt,r)
% Initilizations subroutine (default setting)

% Initialization of variables
if ~isfield(opt,'U') || ~isfield(opt,'V') || ~isfield(opt,'W')
 error('Please initialize U,V,W as opt.U, opt.V, opt.W');
end
 U = opt.U;  V = opt.V;  W = opt.W;

 % stopping criterion
if isfield(opt,'epsilon') 
    epsilon = opt.epsilon;
else
    epsilon = 10^-6; % default 10^-6
end

% max run time (in sec)
if isfield(opt,'timemax') 
    timemax = opt.timemax;
else
    timemax = 60; % default 60
end

% max num iteration
if isfield(opt,'itermax') 
    itermax = opt.itermax;
else
    itermax = 1500; % default 1000
end

% max num iteration of inner loop on each block
if isfield(opt,'inneritermax') 
    inneritermax = opt.inneritermax;
else
    inneritermax = 50; % default 50
end

if isfield(opt,'stepmethod') 
    stepmethod = opt.stepmethod;
else
    stepmethod = 'fromBB'; 
end

if isfield(opt,'modify') 
    modify = opt.modify;
else
    modify = 'n'; 
end

if isfield(opt,'projchoose') 
    projchoose = opt.projchoose;
else
    projchoose = 'before'; 
end

% Store intermediate U,V,W
if isfield(opt,'isStore') 
    isStore = opt.isStore;
     if isStore ==1 % Allocate space to store intermediate U V W
          Ustore = zeros(size(U,1),r,itermax); 
          Vstore = zeros(size(V,1),r,itermax); 
          Wstore = zeros(size(W,1),r,itermax);
     end
else % default no store intermediate
    isStore = 0; 
    Ustore = [];
    Vstore = [];
    Wstore = [];
end
end % EOF ini