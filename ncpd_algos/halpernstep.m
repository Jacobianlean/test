function [beta,U_newproj]=halpernstep(i,U0,U_old,U_oldproj,U_new,stepmethod,modify,projchoose)
U_newproj=max(U_new,0);
%算步长
if strcmp(stepmethod,'common')
    phi=i+1;
elseif strcmp(stepmethod,'anchor')
    if strcmp(modify,'y1')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            U_new=U_new-l*(U_new-U_old); %修正后的Tx_{k-1}
            phi =2*sum(sum((U_old-U0).*(U_new-U_old))) /norm(U_new -U_old, 'fro')^2+1; 
        else%步长的计算用的是投影之后的
            U_new=max(U_new-l*(U_new-U_old),0);
            phi =2*sum(sum((U_oldproj-U0).*(U_new-U_oldproj))) /norm(U_new -U_oldproj, 'fro')^2+1;
        end
    elseif strcmp(modify,'y2')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            U_new=U_new+l*(U_new-U_old); %修正后的Tx_{k-1}
            phi =2*sum(sum((U_old-U0).*(U_new-U_old))) /norm(U_new -U_old, 'fro')^2+1; 
        else%步长的计算用的是投影之后的
            U_new=max(U_new+l*(U_new-U_old),0);
            phi =2*sum(sum((U_oldproj-U0).*(U_new-U_oldproj))) /norm(U_new -U_oldproj, 'fro')^2+1;
        end
    else
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            phi =2*sum(sum((U_old-U0).*(U_new-U_old))) /norm(U_new -U_old, 'fro')^2+1; 
        else%步长的计算用的是投影之后的
            phi =2*sum(sum((U_oldproj-U0).*(U_newproj-U_oldproj))) /norm(U_newproj -U_oldproj, 'fro')^2+1;
        end
    end
elseif strcmp(stepmethod,'fromapp')
    if strcmp(modify,'y1')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            U_new=U_new-l*(U_new-U_old); %修正后的Tx_{k-1}
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_old)))-1;
        else%步长的计算用的是投影之后的
            U_new=max(U_new-l*(U_new-U_old),0);
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_oldproj)))-1;
        end
    elseif strcmp(modify,'y2')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            U_new=U_new+l*(U_new-U_old); %修正后的Tx_{k-1}
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_old)))-1;
        else%步长的计算用的是投影之后的
            U_new=max(U_new+l*(U_new-U_old),0);
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_oldproj)))-1;
        end
    else
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            phi =2*norm(U_new - U0, 'fro')^2 /sum(sum((U_new-U0).*(U_new-U_old)))-1;
        else%步长的计算用的是投影之后的
            phi =2*norm(U_newproj - U0, 'fro')^2 /sum(sum((U_newproj-U0).*(U_newproj-U_oldproj)))-1;
        end
    end
else  %fromBB step
    if strcmp(modify,'y1')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            U_new=U_new-l*(U_new-U_old); %修正后的Tx_{k-1}
            phi =norm(U_new + U_old-2*U0, 'fro')^2 /trace((U_new +U_old-2*U0)'*(U_new-U_old)) ;
        else%步长的计算用的是投影之后的
            U_new=max(U_new-l*(U_new-U_old),0);
            phi =norm(U_new + U_oldproj-2*U0, 'fro')^2 /trace((U_new +U_oldproj-2*U0)'*(U_new-U_oldproj)) ;
        end
    elseif strcmp(modify,'y2')
        l=norm(U_newproj-U_new,'fro')/norm(U_old-U_oldproj,'fro');
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            U_new=U_new+l*(U_new-U_old); %修正后的Tx_{k-1}
            phi =norm(U_new + U_old-2*U0, 'fro')^2 /trace((U_new +U_old-2*U0)'*(U_new-U_old)) ;
        else%步长的计算用的是投影之后的
            U_new=max(U_new+l*(U_new-U_old),0);
            phi =norm(U_new + U_oldproj-2*U0, 'fro')^2 /trace((U_new +U_oldproj-2*U0)'*(U_new-U_oldproj)) ;
        end
    else
        if strcmp(projchoose,'before')%步长的计算用的是投影之前的
            phi =norm(U_new + U_old-2*U0, 'fro')^2 /trace((U_new +U_old-2*U0)'*(U_new-U_old)) ;
        else%步长的计算用的是投影之后的
            phi =norm(U_newproj + U_oldproj-2*U0, 'fro')^2 /trace((U_newproj +U_oldproj-2*U0)'*(U_newproj-U_oldproj)) ;
        end
    end
end
beta = 1/(phi + 1);
end

