function B_new = Normalize(B)

b_norms=vecnorm(B, 2, 1);
 B_new = B ./b_norms ;  
 end