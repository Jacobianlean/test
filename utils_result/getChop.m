function o2 = getChop(o)
% This code is written by Andersen Man Shun Ang.
% This function take in struct "o" and perform
% 1. Extract f_min e_min (for each entry, "per experiment trials")
% 2. Chop f,t,e to the same length 
% 3. Replace o.f, o.e, o.t to the chopped version
% 4. Extract fmin_i emin_i
% IF no a subfield e in o, all process on e is not carried out
%% Input handling
num_trials = size(o,2); % number of struct (number of experimental trials)
%% Does subfiel e exists in o ?
if isfield(o,'e')  hasE = 1;
else               hasE = 0;
end
%% Main
 % get the length of each entry 
 for i = 1 : num_trials
     length_f(i) = numel(find(o(i).f));
     length_t(i) = numel(find(o(i).t));
     if hasE == 1
        length_e(i) = numel(find(o(i).e));
     end
 end
 % get the  min length
 length_f_min = min(length_f);
 length_t_min = min(length_t);
 length_all_min = min([length_f_min length_t_min]);
 if hasE == 1
  length_e_min = min(length_e);
  length_all_min = min([length_all_min length_e_min]);
 end
 % truncate all entry to the min length
 for i = 1 : num_trials
    f(i,:)    = o(i).f(1:length_all_min);
    %f(i,:)    = o(i).f(1:length_f_min);
    fmin_i(i) = min(f(i,:));
    t(i,:)    = o(i).t(1:length_all_min);
    if hasE == 1
      e(i,:)    = o(i).e(1:length_all_min);
      %e(i,:)    = o(i).e(1:length_e_min);
      emin_i(i) = min(e(i,:));
    end
 end
%% Output handling    
o2.f      = f;
o2.t      = t;
o2.fmin_i = fmin_i;
if hasE == 1
 o2.e      = e;
 o2.emin_i = emin_i;
end
end % EOF
