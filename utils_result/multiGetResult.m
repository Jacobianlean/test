function [o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16] = multiGetResult(fmin_i, emin_i, timemax, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16)
% just run getResult multiple times so no need to type that line again and again

o1 = getResult(o1, fmin_i, emin_i, timemax);

if nargin >= 5 o2  = getResult(o2, fmin_i, emin_i, timemax);     end
if nargin >= 6 o3  = getResult(o3, fmin_i, emin_i, timemax);     end
if nargin >= 7 o4  = getResult(o4, fmin_i, emin_i, timemax);     end
if nargin >= 8 o5  = getResult(o5, fmin_i, emin_i, timemax);     end
if nargin >= 9 o6  = getResult(o6, fmin_i, emin_i, timemax);     end
if nargin >=10 o7  = getResult(o7, fmin_i, emin_i, timemax);     end
if nargin >=11 o8  = getResult(o8, fmin_i, emin_i, timemax);     end
if nargin >=12 o9  = getResult(o9, fmin_i, emin_i, timemax);     end
if nargin >=13 o10 = getResult(o10, fmin_i, emin_i, timemax);     end
if nargin >=14 o11 = getResult(o11, fmin_i, emin_i, timemax);     end
if nargin >=15 o12 = getResult(o12, fmin_i, emin_i, timemax);     end
if nargin >=16 o13 = getResult(o13, fmin_i, emin_i, timemax);     end
if nargin >=17 o14 = getResult(o14, fmin_i, emin_i, timemax);     end
if nargin >=18 o15 = getResult(o15, fmin_i, emin_i, timemax);     end
if nargin >=19 o16 = getResult(o16, fmin_i, emin_i, timemax);     end
if nargin >=20 error('at most 16');end
end%EOF