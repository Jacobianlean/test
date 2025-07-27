%% 对不同类型的问题做实验
%% 仅考虑有噪声的情况，这种情况下算法的表现效果较好，回退or外推？
n=2; %4类问题
K=8;  %每类问题生成8个随机张量
m=25;   %25种方法对比
P=10;   %每次随机选取初始点算20次 
tautimes=zeros([m,n*K]);
steps=zeros([m,n*K]);
results=zeros([m,n*K]);  %目标函数最优值
% 考虑四类问题：秩的多少，有无噪声
c=[0.001,0.001]; %相关性
s=[120 120 100];% size of problem
R=[35,35];
l1=[0,1];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
l2=l1;

% 算法的参数选取范围
stepmethodset={'HA','HFA','HFB'};
modifyset={'N','R','E'};
projchooseset={'BF','AF'};


for j=1:n %n类问题
    for k=1:K
        %生成问题
        %Seed = (j-1)*K+k; 
        [X,~]=test_CreateTensor_diff(s,c(j),R(j),l1(j),l2(j));  %不定随机种子
        X=double(X);
        %X=randn(s);
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
            for typestep=1:4
                for typemodify=1:3
                    for typeproj=1:2
                        opt.projchoose=projchooseset{typeproj};
                        opt.modify=modifyset{typemodify};
                        opt.stepmethod=stepmethodset{typestep};
                        [U,V,W,out]=HalpernBCD(X,R(j),opt);
                        step{1+typeproj+(typemodify-1)*2+(typestep-1)*6}(p)=length(out.f);
                        tautime{1+typeproj+(typemodify-1)*2+(typestep-1)*6}(p)=out.t(end);
                        result{1+typeproj+(typemodify-1)*2+(typestep-1)*6}(p)=out.f(end);
                    end
                end    
            end
            
        end

        for i=1:m
            [results(i,(j-1)*K+k),idx]=min(result{i});
            steps(i,(j-1)*K+k)=step{i}(idx);
            tautimes(i,(j-1)*K+k)=tautime{i}(idx);
        end
    end
end
algorithm_name={'HER','HC'};
for typestep=1:3
    for typemodify=1:3
        for typeproj=1:2
            algorithm_name=[algorithm_name,sprintf('%s%s%s',stepmethodset{typestep},modifyset{typemodify},projchooseset{typeproj})];
        end 
    end    
end

%{
 从结果看，AHALS对于秩比较高的情况计算结果较差，试一下proximal ALS
该 BCD_blkUpdt( V, Qv, Pv, inneritermax, inner_delta, algoName );
用 proximal ALS计算
%}
