

X_Start=0;
X_End=100;
Y_Offset=10;

x=linspace(X_Start,X_End);
x=x';
y=x+Y_Offset+randn(size(x));



plot(x,y);
ylim([0,max(y)]);

X = [ones(size(x)) x];
[b,bint,r,rint,stats] = regress(y,X);

Mean_Individual=X*b;

Y_Detrend=r;

Y_Individual=y-Mean_Individual;


plot(x,Y_Detrend,x,Y_Individual)





