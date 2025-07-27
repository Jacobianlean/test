function  [A_new,A_new_proj]=MNLS_Halpern(X,B,A_old_proj,A_old,A0,update,i,modify,exchoose)
% X:m\times n; B:n\times r; ASTAR: m\times r，上一步的A（这里的ASTAR本质上就是A_old）;
%{
[~,D]=eig(B'*B);
L=max(diag(D));
mu=min(diag(D));
lambda=lam(L,mu);
%}
lambda=0.01;

r=size(B);
A_new=(lambda*A_old_proj+X*B)/(B'*B+lambda*eye(r(2))); % 做ALS
A_new_proj=max(A_new,0);

%算步长
if strcmp(update,'common')
    phi=i+1;
elseif strcmp(update,'anchor')
    if strcmp(modify,'y1')%做修正
        l=norm(A_new_proj-A_new,'fro')/norm(A_old-A_old_proj,'fro');
        A_new=A_new-l*(A_new-A_old); %修正后的Tx_{k-1}
    elseif strcmp(modify,'y2')
        l=norm(A_new_proj-A_new,'fro')/norm(A_old-A_old_proj,'fro');
        A_new=A_new+l*(A_new-A_old); %修正后的Tx_{k-1}
    end
    phi =2*sum(sum((A_old-A0).*(A_new-A_old))) /norm(A_new -A_old, 'fro')^2+1;
elseif strcmp(update,'ours')
    if strcmp(modify,'y1')%做修正
        l=norm(A_new_proj-A_new,'fro')/norm(A_old-A_old_proj,'fro');
        A_new=A_new-l*(A_new-A_old); %修正后的Tx_{k-1}
    elseif strcmp(modify,'y2')
        l=norm(A_new_proj-A_new,'fro')/norm(A_old-A_old_proj,'fro');
        A_new=A_new+l*(A_new-A_old); %修正后的Tx_{k-1}
    end
    phi =2*norm(A_new -A0, 'fro')^2/sum(sum((A_new-A0).*(A_new-A_old)))-1;
else
    if strcmp(modify,'y1')%做修正
        l=norm(A_new_proj-A_new,'fro')/norm(A_old-A_old_proj,'fro');
        A_new=A_new-l*(A_new-A_old); %修正后的Tx_{k-1}，这里由于本身Halpern加速的步长比较激进，所以采用往回走的方式
    elseif strcmp(modify,'y2')
        l=norm(A_new_proj-A_new,'fro')/norm(A_old-A_old_proj,'fro');
        A_new=A_new+l*(A_new-A_old); %修正后的Tx_{k-1}
    end
    phi =norm(A_new + A_old-2*A0, 'fro')^2 /trace((A_new +A_old-2*A0)'*(A_new-A_old)) ;
end
a = 1/(phi + 1);
%这里是用投影后的做外推，也可以用投影前的试一试
if strcmp(exchoose,'after')
    A_new_proj=max(A_new,0);
    A_new=(1-a)*A_new_proj+a*A0;
else
    %用投影前的做外推
    A_new=(1-a)*A_new+a*A0;
    A_new_proj=max(A_new,0); %做投影
end
%这里无法保证非负性，所以要先做外推再做投影
end
