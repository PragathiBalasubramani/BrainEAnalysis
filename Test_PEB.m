%%
hm = headModel.loadDefault;
nw = load('Networks_BrainE.mat','network'); % obtain network variable involving a mask for different networks
funcnetwork = nw.network;
x = double(funcnetwork(end).mask);
X = x*ones(1,20)+0.1*randn(length(x),20);

norm_K = norm(hm.K);
H = hm.K/norm_K;
Delta = hm.L/norm_K;
H = bsxfun(@rdivide,H,sqrt(sum(H.^2)));
Y = H*X;
blocks = hm.indices4Structure(hm.atlas.label);
solver = PEB(H, Delta, blocks);
options = solver.defaultOptions;
options.smoothLambda = false;

options.lambdaMin = 1e-0;
% hm.plotOnModel(X,Y)


%%
[Xhat,lambda, ~, gamma, logE] = solver.update(Y,[],[],options);
% hm.plotOnModel(Xhat,hm.K*Xhat);
Cy = Y*Y'/20;
logE_k = zeros(length(funcnetwork),1);
for net=1:length(funcnetwork)
    indNet = find(ismember(hm.atlas.label,funcnetwork(net).ROI));
    logE_k(net) = solver.calculateLogEvidence(Cy,lambda,gamma,indNet);
end
BF = 2*(logE_k-logE);