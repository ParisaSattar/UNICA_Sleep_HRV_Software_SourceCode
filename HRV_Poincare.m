function[SD1,SD2,SD12]=HRV_Poincare(RR_intervals,plotting)
%figure

global px6 fs PP_Tab

% Generate random data for illustration
rng(1); % For reproducibility
RR_intervals=(RR_intervals/fs)*1000;
RRn = RR_intervals(1:end-1); % Random RR(n) values
RRn1 = RR_intervals(2:end); % Random RR(n+1) values
RRn=RRn';
RRn1=RRn1';
%Calculate the mean of the data
mu = mean([RRn, RRn1]);

% Center the data
data_centered = [RRn, RRn1] - mu;

% Compute the covariance matrix
cov_matrix = cov(data_centered);

% Perform eigen decomposition
[V, D] = eig(cov_matrix);
[~, idx] = sort(diag(D), 'descend');
V = V(:, idx);
D = D(idx, idx);

% Standard deviations along the principal components
SD2 = sqrt(D(1,1));
SD1 = sqrt(D(2,2));
SD12=SD1/SD2;
if plotting==1
% Plot the data points
if exist('px6','var')
    delete(px6)
end
px6 = axes('Parent', PP_Tab, 'Position', [0.6 0.35 0.34 0.55], 'Visible', 'on');
scatter(px6, RRn, RRn1, 'b.');
hold(px6, 'on');

% Plot the principal components (half axis)
pc1 = V(:,2) * SD1;
pc2 = V(:,1) * SD2;
h1 = plot(px6, [mu(1), mu(1) + pc1(1)], [mu(2), mu(2) + pc1(2)], 'k', 'LineWidth', 1, 'DisplayName', 'SD1');
h2 = plot(px6, [mu(1), mu(1) + pc2(1)], [mu(2), mu(2) + pc2(2)], 'k', 'LineWidth', 2, 'DisplayName', 'SD2');

% Plot the ellipse
theta = linspace(0, 2*pi, 100);
ellipse_x = SD1 * cos(theta);
ellipse_y = SD2 * sin(theta);
ellipse_coords = [ellipse_y;ellipse_x]' * V' + mu;

plot(px6, ellipse_coords(:,1), ellipse_coords(:,2), 'r', 'LineWidth', 2);

% Add labels and title
xlabel(px6, 'RR(n) [ms]');
ylabel(px6, 'RR(n+1) [ms]');
tb = axtoolbar(px6,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});

% Add legend for principal components only
legend(px6, [h1, h2]);

hold(px6, 'off');
RR_intervals=(RR_intervals*fs)/1000;
end
end