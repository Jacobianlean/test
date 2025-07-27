% 执行分解
T = tucker_als(tensor(imageStack), 283, 'tol', 1e-4, 'maxiters', 50, 'printitn', 5);  %返回的T是包含G，U1，U2，U3的结构体
