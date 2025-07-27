%% 对不同类型的问题做实验
%% 仅考虑有噪声的情况，这种情况下算法的表现效果较好，回退or外推？
m=25;   %25种方法对比
P=10;   %每次随机选取初始点算20次 
R=10;
tautimes=zeros([m,1]);
steps=zeros([m,1]);
results=zeros([m,1]);  %目标函数最优值
% 考虑四类问题：秩的多少，有无噪声
% 算法的参数选取范围
stepmethodset={'common','anchor','fromapp','fromBB'};
modifyset={'n','y1','y2'};
projchooseset={'before','after'};

step=cell([m,1]);tautime=cell([m,1]);result=cell([m,1]);
for i=1:m
    step{i}=zeros([P,1]);tautime{i}=zeros([P,1]);result{i}=zeros([P,1]);
end
for p=1:P
    opt.U=randn(s(1),R);
    opt.V=randn(s(2),R);
    opt.W=randn(s(3),R);
    [U,V,W,out] = herBCD(X,R,opt);
    step{1}(p)=length(out.f);
    tautime{1}(p)=out.t(end);
    result{1}(p)=out.f(end);
    for typestep=1:4
        for typemodify=1:3
            for typeproj=1:2
                opt.projchoose=projchooseset{typeproj};
                opt.modify=modifyset{typemodify};
                opt.stepmethod=stepmethodset{typestep};
                [U,V,W,out]=HalpernBCD(X,R,opt);
                step{1+typeproj+(typemodify-1)*2+(typestep-1)*6}(p)=length(out.f);
                tautime{1+typeproj+(typemodify-1)*2+(typestep-1)*6}(p)=out.t(end);
                result{1+typeproj+(typemodify-1)*2+(typestep-1)*6}(p)=out.f(end);
            end
        end    
    end
    
end

for i=1:m
    [results(i),idx]=min(result{i});
    steps(i)=step{i}(idx);
    tautimes(i)=tautime{i}(idx);
end

algorithm_name={'HER'};
for typestep=1:4
    for typemodify=1:3
        for typeproj=1:2
            algorithm_name=[algorithm_name,sprintf('Halpern_%s_%s_%s',stepmethodset{typestep},modifyset{typemodify},projchooseset{typeproj})];
        end 
    end    
end

%{
 从结果看，AHALS对于秩比较高的情况计算结果较差，试一下proximal ALS
该 BCD_blkUpdt( V, Qv, Pv, inneritermax, inner_delta, algoName );
用 proximal ALS计算
%}
