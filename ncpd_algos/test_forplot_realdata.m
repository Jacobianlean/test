T = tucker_als(tensor(imageStack), 30);
m=20;   
%T=gas;  
T.U{1}=T.U{1}+randn(size(T.U{1}));
T.U{2}=T.U{2}+randn(size(T.U{2}));
T.U{3}=T.U{3}+randn(size(T.U{3}));
T.core=T.core+randn(size(T.core));
Y={T.U{1},T.U{2},T.U{3},double(T.core)};
s=size(T);% size of problem
%s=size(Y);
R=10;
o1(m) = struct('f',[],'t',[]);
o2(m) = struct('f',[],'t',[]);
o3(m) = struct('f',[],'t',[]);
for i=1:m
    opt.U=randn(s(1),R);
    opt.V=randn(s(2),R);
    opt.W=randn(s(3),R);
    [~,~,~,out1] = herBCD(Y,R,opt);
    o1(i).f=out1.f;
    o1(i).t=out1.t;
    opt.stepmethod='fromapp';
    opt.modify='y2'; 
    opt.projchoose='before';
    [~,~,~,out2] = HalpernBCD(Y,R,opt);
    o2(i).f=out2.f; 
    o2(i).t=out2.t;
    opt.stepmethod='fromBB';
    opt.modify='y2';
    opt.projchoose='before';
    [~,~,~,out3] = HalpernBCD(Y,R,opt);
    o3(i).f=out3.f; 
    o3(i).t=out3.t;
end


