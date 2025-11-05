function H = fitHomography(fixedPts,movingPts)
% Brief: 根据fixedPts和movingPts对应点做单应矩阵估计
% Details:
%   使用 Direct Linear Transformation (DLT) + SVD 求解 3×3 单应矩阵 H，
%   满足 movingPts ≈ H * fixedPts（齐次坐标）。
%   至少需要 4 对非共线的对应点。
%   返回的 H 已归一化使得 H(3,3)=1。
%
% Syntax:
%   H = fitHomography(fixedPts,movingPts)
%
% Inputs:
%   fixedPts  - [m×2] double, 源平面点坐标 [x1,y1; ...]
%   movingPts - [m×2] double, 目标平面点坐标 [x2,y2; ...]
%
% Outputs:
%   H - [3×3] double, 单应矩阵（右乘齐次坐标），满足
%       [x2 y2 1]' ≈ H * [x1 y1 1]'
%
% Example:
%   fixed  = [0 0; 0 1; 1 1; 1 0];
%   moving = [0 0; 0 2; 3 2; 3 0];
%   H = fitHomography(fixed,moving)
%   % → H ≈ [3 0 0; 0 2 0; 0 0 1]（拉伸变换）
%
% See also: fitgeotform2d,estgeotform2d,svd

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         05-Nov-2025 09:57:31
% Version history revision notes:
%                                  None
% Implementation In Matlab R2026a
% Copyright © 2025 TheMatrix.All Rights Reserved.
%
arguments
    fixedPts (:,2) {mustBeNumeric,mustGteatThan4}
    movingPts (:,2) {mustBeNumeric,mustGteatThan4}
end

numpts = size(fixedPts,1);
onesM = ones(numpts,1);
zerosM = zeros(numpts,1);

x1 = fixedPts(:,1);
y1 = fixedPts(:,2);
x2 = movingPts(:,1);
y2 = movingPts(:,2);

% 构造 DLT 系数矩阵 A（2m×9），每对点贡献两行
% 第 1 行：x' 方程 → [x y 1 0 0 0 -x'x -y'x -x']
% 第 2 行：y' 方程 → [0 0 0 x y 1 -x'y -y'y -y']
A = [x1,y1,onesM, zerosM,zerosM,zerosM, -x1.*x2,-x2.*y1,-x2;
    zerosM,zerosM,zerosM,x1,y1,onesM,-x1.*y2,-y1.*y2,-y2];

% SVD 求零空间：A*h = 0，h 为 9×1 向量
% V 的最后一列对应最小奇异值，即最佳解
[~,~,V] = svd(A);

% 提取并归一化（h33=1）
Ho = V(:,end);
Ho = Ho./Ho(end);
H = reshape(Ho,3,3);
end

function mustGteatThan4(pts)
if size(pts,1)<4
    error("At least 4 corresponding points need");
end
end