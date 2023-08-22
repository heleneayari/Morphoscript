clc
clear
close all

dossier='/data1/thoman/ownCloud/Git/StripyStripes/Test_images/results/';


files=dir([dossier,'*_FourierAnalysis.mat']);
F=length(files);


%% Create table
Tf= array2table(zeros(0,19));
Tf.Properties.VariableNames = {'Distribution', 'Order', 'Wavelengthmean',...
           'Wavelengthmed','MaskPixels','OtsuPixels','MaskMicrons','OtsuMicrons','Coverage',...
           'MeanImIntensity','MaxImIntensity','MeanProtIntensity','Compactness','Roundneess',...
           'Rectangularity','Elongation','Ellipsoidal','Eccentricity','MeanBackCellIntensity'};
       
%%
for ii=1:F
    
load([dossier,files(ii).name])
load([dossier,files(ii).name(1:end-20),'_ShapeAnalysis.mat'])

T=table(FIA.Distribution,FIA.Order,FIA.Wavelengthmean,FIA.Wavelengthmed,SA.MaskPixels,...
    SA.OtsuPixels,SA.MaskMicrons,SA.OtsuMicrons,SA.Coverage,SA.MeanImageIntensity,...
    SA.MaxImageIntensity,SA.MeanProteinIntensity,SA.Compactness,SA.Roundness,SA.Rectangularity,...
    SA.Elongation,SA.Ellipsoidal,SA.Eccentricity,SA.MeanBackCellIntensity);
T.Properties.RowNames={files(ii).name(1:end-20)};
T.Properties.VariableNames=Tf.Properties.VariableNames ;
Tf=[Tf;T];
clear T

    
end

save([dossier,'myresult.mat'],'Tf')
writetable(Tf,[dossier,'results.xls'],'WriteRowNames',true)

 