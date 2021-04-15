function h=circle(x,y,r,varargin)
alpha=0:0.01:2*pi;
xp=r*cos(alpha);
yp=r*sin(alpha);
h=plot(x+xp,y+yp,varargin{:});
plot(x,y,'+r',varargin{:})
end