function [o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16] = multiChop(o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16)
% just run getChop multiple times so no need to type that line again and again
o1 = getChop(o1);
if nargin >= 2 o2  = getChop(o2);  end
if nargin >= 3 o3  = getChop(o3);  end
if nargin >= 4 o4  = getChop(o4);  end
if nargin >= 5 o5  = getChop(o5);  end
if nargin >= 6 o6  = getChop(o6);  end
if nargin >= 7 o7  = getChop(o7);  end
if nargin >= 8 o8  = getChop(o8);  end
if nargin >= 9 o9  = getChop(o9);  end
if nargin >=10 o10 = getChop(o10);  end
if nargin >=11 o11 = getChop(o11);  end
if nargin >=12 o12 = getChop(o12);  end
if nargin >=13 o13 = getChop(o13);  end
if nargin >=14 o14 = getChop(o14);  end
if nargin >=15 o15 = getChop(o15);  end
if nargin >=16 o16 = getChop(o16);  end
if nargin >=17 error('at most 16');end
end%EOF