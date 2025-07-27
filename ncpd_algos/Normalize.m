function B_new = Normalize(B)
% 做列单位化
b_norms=vecnorm(B, 2, 1);
 B_new = B ./b_norms ;  
 end