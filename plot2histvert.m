function plot2histvert(X,ind,legendy,posleg)


dist='normal';
dist='kernel';
al=0.2;
nb=10;
ll=(max(X)-min(X))./nb;
edges=min(X):ll:max(X);
ll=max(X)./nb;
% edges=0:ll:max(X);


binwidth = edges(2)-edges(1); % Finds the width of each bin


x=linspace(min(edges),max(edges),1000);


 


pd = fitdist(X(ind),dist);
%area = numel(X(ind)) * binwidth;
area =  binwidth;
y = area * pdf(pd,x);

h=histogram(X(ind),edges,'Normalization','probability');
%h=histogram(X(ind),edges);
h(1).FaceColor = 'b';
h(1).FaceAlpha=al;
hold on
plot(x,y,'b')
% legend(hh,legend{1})
pd2 = fitdist(X(~ind),dist);
y2=area*pdf(pd2,x);

h2=histogram(X(~ind),edges,'Normalization','probability');
h2(1).FaceColor = 'r';
h2(1).FaceAlpha=al;
hold on
plot(x,y2,'r')
% set(gca,'CameraUpVector',[1,0,0],'YTick',[]);%,'Ylim',[0 MM]);
%set(gca,'CameraUpVector',[1,0,0]);%,'Ylim',[0 MM]);
%legend(legend)

aa=xlabel(legendy);
% bb=ylabel('percentage')
% bb.Units='Normalized'
% bb.Position(1)=-0.15;
aa.Units='Normalized';
aa.Position(2)=posleg;

% ylabel(legendy,'Position',[0.12 0 -0.1])
axis tight