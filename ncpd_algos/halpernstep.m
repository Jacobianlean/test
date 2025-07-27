function [beta,U_newproj]=halpernstep(i,U0,U_old,U_oldproj,U_new,stepmethod,modify,projchoose)
% Computes Halpern step size
% === Inputs ==============================================================
%  i            : current iteration step
%  U0           : initial matrix U
%  U_old        : current U before projection
%  U_oldproj    : current U after projection
%  U_new        : matrix after AHALS
%  stepmethod   : 'common','anchor','fromapp','fromBB'(default)
%  modify       : 'y1','y2','n'(default)
%  projchoose   : 'before','after'(default)
% === Output ==============================================================
% beta          : Halpern step size
% U_newproj     : U_new after projection


U_newproj=max(U_new,0);

if strcmp(stepmethod,'common')
    phi=i+1;
elseif strcmp(stepmethod,'anchor')
    if strcmp(modify,'y1')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')
            U_new=U_new-l*(U_new-U_old); 
            phi =2*sum(sum((U_old-U0).*(U_new-U_old))) /norm(U_new -U_old, 'fro')^2+1; 
        else
            U_new=max(U_new-l*(U_new-U_old),0);
            phi =2*sum(sum((U_oldproj-U0).*(U_new-U_oldproj))) /norm(U_new -U_oldproj, 'fro')^2+1;
        end
    elseif strcmp(modify,'y2')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')
            U_new=U_new+l*(U_new-U_old); 
            phi =2*sum(sum((U_old-U0).*(U_new-U_old))) /norm(U_new -U_old, 'fro')^2+1; 
        else
            U_new=max(U_new+l*(U_new-U_old),0);
            phi =2*sum(sum((U_oldproj-U0).*(U_new-U_oldproj))) /norm(U_new -U_oldproj, 'fro')^2+1;
        end
    else
        if strcmp(projchoose,'before')
            phi =2*sum(sum((U_old-U0).*(U_new-U_old))) /norm(U_new -U_old, 'fro')^2+1; 
        else
            phi =2*sum(sum((U_oldproj-U0).*(U_newproj-U_oldproj))) /norm(U_newproj -U_oldproj, 'fro')^2+1;
        end
    end
elseif strcmp(stepmethod,'fromapp')
    if strcmp(modify,'y1')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')
            U_new=U_new-l*(U_new-U_old); 
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_old)))-1;
        else
            U_new=max(U_new-l*(U_new-U_old),0);
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_oldproj)))-1;
        end
    elseif strcmp(modify,'y2')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')
            U_new=U_new+l*(U_new-U_old); 
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_old)))-1;
        else
            U_new=max(U_new+l*(U_new-U_old),0);
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_oldproj)))-1;
        end
    else
        if strcmp(projchoose,'before')
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_old)))-1;
        else
            phi =2*norm(U_newproj - U0, 'fro')^2 /sum(sum((U_newproj-U0).*(U_newproj-U_oldproj)))-1;
        end
    end
else  
    if strcmp(modify,'y1')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')
            U_new=U_new-l*(U_new-U_old); 
            phi =norm(U_new + U_old-2*U0, 'fro')^2 /trace((U_new +U_old-2*U0)'*(U_new-U_old)) ;
        else
            U_new=max(U_new-l*(U_new-U_old),0);
            phi =norm(U_new + U_oldproj-2*U0, 'fro')^2 /trace((U_new +U_oldproj-2*U0)'*(U_new-U_oldproj)) ;
        end
    elseif strcmp(modify,'y2')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')
            U_new=U_new+l*(U_new-U_old); 
            phi =norm(U_new + U_old-2*U0, 'fro')^2 /trace((U_new +U_old-2*U0)'*(U_new-U_old)) ;
        else
            U_new=max(U_new+l*(U_new-U_old),0);
            phi =norm(U_new + U_oldproj-2*U0, 'fro')^2 /trace((U_new +U_oldproj-2*U0)'*(U_new-U_oldproj)) ;
        end
    else
        if strcmp(projchoose,'before')
            phi =norm(U_new + U_old-2*U0, 'fro')^2 /trace((U_new +U_old-2*U0)'*(U_new-U_old)) ;
        else
            phi =norm(U_newproj + U_oldproj-2*U0, 'fro')^2 /trace((U_newproj +U_oldproj-2*U0)'*(U_newproj-U_oldproj)) ;
        end
    end
end
beta = 1/(phi + 1);
end

