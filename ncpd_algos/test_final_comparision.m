%% 对不同类型的问题做实验
%% 仅考虑有噪声的情况，这种情况下算法的表现效果较好，回退or外推？
n=2; %4类问题
K=8;  %每类问题生成8个随机张量
m=3;   %25种方法对比
P=10;   %每次随机选取初始点算20次 
tautimes=zeros([m,n*K]);
steps=zeros([m,n*K]);
results=zeros([m,n*K]);  %目标函数最优值
% 考虑四类问题：秩的多少，有无噪声
c=[0.01,0.01]; %相关性
s=[100 100 100];% size of problem
R=[5,5];
l1=[0,1];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
l2=l1;

% 算法的参数选取范围
stepmethodset={'common','anchor','fromapp','fromBB'};
modifyset={'n','y1','y2'};
projchooseset={'before','after'};


for j=1:n %n类问题
    for k=1:K
        %生成问题
        %Seed = (j-1)*K+k; 
        [X,~]=test_CreateTensor_diff(s,c(j),R(j),l1(j),l2(j));  %不定随机种子
        X=double(X);
        step=cell([m,1]);tautime=cell([m,1]);result=cell([m,1]);
        for i=1:m
            step{i}=zeros([P,1]);tautime{i}=zeros([P,1]);result{i}=zeros([P,1]);
        end
        for p=1:P
            opt.U=randn(s(1),R(j));
            opt.V=randn(s(2),R(j));
            opt.W=randn(s(3),R(j));
            [U,V,W,out] = herBCD(X,R(j),opt);
            step{1}(p)=length(out.f);
            tautime{1}(p)=out.t(end);
            result{1}(p)=out.f(end);
            opt.stepmethod='fromapp';
            opt.modify='y2';
            opt.projchoose='before';
            [~,~,~,out] = HalpernBCD(X,R(j),opt);
            step{2}(p)=length(out.f);
            tautime{2}(p)=out.t(end);
            result{2}(p)=out.f(end);
            opt.stepmethod='fromBB';
            opt.modify='y2';
            opt.projchoose='before';
            [~,~,~,out] = HalpernBCD(X,R(j),opt);
            step{3}(p)=length(out.f);
            tautime{3}(p)=out.t(end);
            result{3}(p)=out.f(end);
        end

        for i=1:m
            [results(i,(j-1)*K+k),idx]=min(result{i});
            steps(i,(j-1)*K+k)=step{i}(idx);
            tautimes(i,(j-1)*K+k)=tautime{i}(idx);
        end
    end
end
algorithm_name={'HER','fromapp_y2_before','fromBB_y2_before'};

%{
algorithm_name={'HER'};
for typestep=1:4
    for typemodify=1:3
        for typeproj=1:2
            algorithm_name=[algorithm_name,sprintf('Halpern_%s_%s_%s',stepmethodset{typestep},modifyset{typemodify},projchooseset{typeproj})];
        end 
    end    
end
%}
