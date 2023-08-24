
function makePretty

FontName = 'Helvetica';
set(groot, 'defaultAxesFontName', FontName);
set(groot, 'defaultTextFontName', FontName);
% 
FontSize = 42;
%FontSize = 24;
set(groot, 'defaultAxesFontSize', FontSize);

FontSize = 24;
%FontSize = 12;
set(groot, 'defaultLegendFontSize', FontSize);
set(groot, 'defaultTextFontSize', FontSize);
LineWidth = 3;
%LineWidth = 1;
set(groot, 'defaultAxesLineWidth', LineWidth);
set(groot, 'defaultLineLineWidth', LineWidth);

MarkerSize = 10;
%MarkerSize = 1;
set(groot, 'defaultLineMarkerSize', MarkerSize);

set(groot, 'defaultAxesBox', 'on');
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultColorbarTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultPolaraxesTickLabelInterpreter', 'latex');