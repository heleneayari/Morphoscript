clear
close all
clc
makePretty

dossierfourier='Test_images/results/';


nom{1}='myresult1.mat';
nom{2}='myresult2.mat';
load([dossierfourier,nom{1}]);

ll=size(Tf,1);
MP(:,1)=[Tf.MaskMicrons];
OP(:,1)=[Tf.OtsuMicrons];
C(:,1)=[Tf.Coverage];
MII(:,1)=[Tf.MeanImIntensity];
MIM(:,1)=[Tf.MaxImIntensity];
MPI(:,1)=[Tf.MeanProtIntensity];
MBI(:,1)=[Tf.MeanBackCellIntensity];
CP(:,1)=[Tf.Compactness];
Ro(:,1)=[Tf.Roundness];
Rc(:,1)=[Tf.Rectangularity];
E(:,1)=ones(1,ll)-[Tf.Elongation]';
Ell(:,1)=[Tf.Ellipsoidal];
Ecc(:,1)=[Tf.Eccentricity];
Order(:,1)=[Tf.Order];
stddis(:,1)=[Tf.Distribution];
wl(:,1)=[Tf.Wavelengthmean];



tp=true(ll,1);
load([dossierfourier,nom{2}]);

ll2=size(Tf,1);
tp2=false(ll2,1);
tp=[tp;tp2];
MP=[MP(:);[Tf.MaskMicrons]];
OP=[OP(:);[Tf.OtsuMicrons]];
C=[C(:);[Tf.Coverage]];
MII=[MII(:);[Tf.MeanImIntensity]];
MIM=[MIM(:);[Tf.MaxImIntensity]];
MPI=[MPI(:);[Tf.MeanProtIntensity]];
MBI=[MBI(:);[Tf.MeanBackCellIntensity]];
CP=[CP(:);[Tf.Compactness]];
Ro=[Ro(:);[Tf.Roundness]];
Rc=[Rc(:);[Tf.Rectangularity]];
E=[E(:);1-[Tf.Elongation]];
Ell=[Ell(:);[Tf.Ellipsoidal]];
Ecc=[Ecc(:);[Tf.Eccentricity]];
Order=[Order(:);[Tf.Order]];
stddis=[stddis(:);[Tf.Distribution]];
wl=[wl(:);[Tf.Wavelengthmean]];

MPI=MPI./MBI;





%% New complete figure
leg={'Pluricyte','Usual'};
numhist=4;
posleg=-0.13;
figure('Position',[570 270 800 405],'Name','Fi3stripy');
figToolbarFix
subaxis(2,numhist,1,'SpacingVert',0.1,'MR',0.05,'ML',0.05,'PaddingTop',-0.06,'PaddingBottom',0.02);
%plot2histvert(MPI,tp,'Area ($\mu m^2$)',posleg)
plot2histvert(MP,tp,'Area ($\mu m^2$)',posleg)
h = findobj(gca,'Type','histogram');
legend(h,leg)
subaxis(2,numhist,2);
plot2histvert(CP,tp,'Compactness',posleg)
subaxis(2,numhist,3);
plot2histvert(E,tp,'Elongation',posleg)
subaxis(2,numhist,4);
plot2histvert(C,tp,'Coverage',posleg)

posleg=-0.18;
subaxis(2,numhist,5,'SpacingVert',0.2,'MR',0.05,'ML',0.05,'PaddingBottom',0.02);
plot2histvert(MPI,tp,'Protein Intensity',posleg)
subaxis(2,numhist,6);

plot2histvert(Order,tp,'Order',posleg)

subaxis(2,numhist,7);
plot2histvert(stddis,tp,'Dispersion (radian)',posleg)
subaxis(2,numhist,8);
plot2histvert(wl,tp,'Spacing ($\mu m$)',posleg)

%%
