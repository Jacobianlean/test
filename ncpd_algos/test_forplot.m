%% 对不同类型的问题做实验
%% 仅考虑有噪声的情况，这种情况下算法的表现效果较好，回退or外推？
m=20;   %每种方法运行20次
c=0.9; %相关性
s=[11 15 20];% size of problem
R=3;
l1=0;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
l2=l1;
% 算法的参数选取范围
o1(m) = struct('f',[],'t',[],'e',[]);
o2(m) = struct('f',[],'t',[],'e',[]);
o3(m) = struct('f',[],'t',[],'e',[]);
[X,~,X_true]=test_CreateTensor_diff(s,c,R,l1,l2,1);  %不定随机种子，另外真实矩阵因子要非负
for i=1:m
    opt.U=randn(s(1),R);
    opt.V=randn(s(2),R);
    opt.W=randn(s(3),R);
    Y=double(X);
    [~,~,~,out1] = herBCD(Y,R,opt);
    %出结果out.Ustore之后计算error
    [e_mean1,e_all1] = computeE(out1.Ustore,out1.Vstore,out1.Wstore,X_true{1},X_true{2},X_true{3});
    o1(i).f=out1.f;
    o1(i).e=e_mean1;
    o1(i).t=out1.t;
    opt.stepmethod='fromapp';
    opt.modify='y2';
    opt.projchoose='before';
    [~,~,~,out2] = HalpernBCD(Y,R,opt);
    [e_mean2,e_all2] = computeE(out2.Ustore,out2.Vstore,out2.Wstore,X_true{1},X_true{2},X_true{3});
    o2(i).f=out2.f;
    o2(i).e=e_mean2;
    o2(i).t=out2.t;
    opt.stepmethod='fromBB';
    opt.modify='y2';
    opt.projchoose='before';
    [~,~,~,out3] = HalpernBCD(Y,R,opt);
    [e_mean3,e_all3] = computeE(out3.Ustore,out3.Vstore,out3.Wstore,X_true{1},X_true{2},X_true{3});
    o3(i).f=out3.f; 
    o3(i).e=e_mean3;
    o3(i).t=out3.t;
end

