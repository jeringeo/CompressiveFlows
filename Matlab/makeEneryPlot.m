function makeEneryPlot(flows)
rmse = sqrt(mean(abs(flows(:)).^2));
ft = fftshift(fftn(flows))/sqrt(numel(flows));
ft = abs(ft(:)).^2;
ft = sort(ft); ft = ft(end:-1:1);
ftc = cumsum(ft); 

n = 1000;
plot(sqrt(ftc(1:n)/numel(ft)),'r-o');
hold on;
plot([0,n], [rmse, rmse],'g');
hold on;
plot([0,n], [rmse, rmse]-1,'c');
ylim([0,10]);
grid on;
end

