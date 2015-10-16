function Plot_GM(X,k,W,M,V,EllipseColor,displaypoints)
%%
% Plot_GM(X,k,W,M,V,EllipseColor)
% plot the data point X 
% plot the means of the GMM M
% give a illustraton of the covariances V using ellipses
% Ellipse Color: specify the color of the Ellipse :  '-b'
% k: number of gaussians components.
% W: prior of the gaussian components.

[n,d] = size(X);
if d>2
    disp('Can only plot 1 or 2 dimensional applications!/n');
    return
end
S = zeros(d,k);
R1 = zeros(d,k);
R2 = zeros(d,k);
S
R1
R2
for i=1:k,  % Determine plot range as 4 x standard deviations
    S(:,i) = sqrt(diag(V(:,:,i)));
    R1(:,i) = M(:,i)-4*S(:,i);
    R2(:,i) = M(:,i)+4*S(:,i);
end
Rmin = min(min(R1));
Rmax = max(max(R2));
R = [Rmin:0.001*(Rmax-Rmin):Rmax];
hold on
if d==1,
    Q = zeros(size(R));
    for i=1:k,
        P = W(i)*normpdf(R,M(:,i),sqrt(V(:,:,i)));
        Q = Q + P;
        plot(R,P,'r-');
        grid on,
    end
    plot(R,Q,'k-');
    xlabel('X');
    ylabel('Probability density');
else % d==2
    if displaypoints
        plot(X(:,1),X(:,2),'r.');
    end
        
    for i=1:k,
        h=Plot_Std_Ellipse(M(:,i),V(:,:,i),EllipseColor);
    end
    xlabel('1^{st} dimension');
    ylabel('2^{nd} dimension');
    minx=min(X(:));
    maxx=max(X(:));
    axis([minx maxx minx maxx])
    %axis([Rmin Rmax Rmin Rmax])
    %axis([0.35 0.46  0.27 0.34])
end
title('Gaussian Mixture mean and standart deviations');
%%%%%%%%%%%%%%%%%%%%%%%%
%%%% End of Plot_GM %%%%
%%%%%%%%%%%%%%%%%%%%%%%%

