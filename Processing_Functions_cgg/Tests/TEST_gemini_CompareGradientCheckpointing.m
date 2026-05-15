% =========================================================================
% Gradient Checkpointing Proof-of-Concept in MATLAB
% Compares 3 Methods: Standard, Unsynced Checkpointing, and Synced Checkpointing
% Now includes Branching VAE + Classifier architecture support!
% =========================================================================

function TEST_gemini_CompareGradientCheckpointing(useDropout, networkWidth, dropoutProb, taskType, archType, classWeight)
    if nargin < 1, useDropout = true; end
    if nargin < 2, networkWidth = 16; end
    if nargin < 3, dropoutProb = 0.5; end
    if nargin < 4, taskType = 'branching_vae'; end % 'sine', 'classification', 'stochastic_ae', 'branching_vae'
    if nargin < 5, archType = 'mlp_tanh'; end 
    if nargin < 6, classWeight = 1.0; end % Weight multiplier for Classification loss

    disp('===============================================================');
    disp(' GRADIENT CHECKPOINTING TEST SUITE (3-WAY COMPARISON)');
    disp('===============================================================');
    fprintf('Task: %s | Architecture: %s\n', upper(taskType), upper(archType));
    
    if strcmp(taskType, 'branching_vae')
        fprintf('--- Executing Branching VAE + Classifier (Class Weight: %.2f) ---\n', classWeight);
        runBranchingVAE(useDropout, networkWidth, dropoutProb, archType, classWeight);
        return; % Branching uses specialized logic, so we exit here after running
    end
    
    % ... (The rest of the linear sequential logic would go here, 
    %      but for brevity in this example, we jump straight to the new VAE!)
    disp('Please run with taskType = "branching_vae" for this specific example.');
end

% =========================================================================
% SPECIALIZED RUNNER: BRANCHING VAE + CLASSIFIER
% =========================================================================
function runBranchingVAE(useDropout, networkWidth, dropoutProb, archType, classWeight)
    
    % 1. DATA SETUP (Concentric Circles)
    numObservations = 256;
    theta = linspace(0, 4*pi, numObservations/2);
    r1 = randn(1, numObservations/2) * 0.3 + 1.5;
    r2 = randn(1, numObservations/2) * 0.3 + 4.0;
    
    X_mat = [[r1 .* cos(theta); r1 .* sin(theta)], [r2 .* cos(theta); r2 .* sin(theta)]];
    Y_mat = [repmat([1; 0], 1, numObservations/2), repmat([0; 1], 1, numObservations/2)];
    
    idx = randperm(numObservations);
    [X1_grid, X2_grid] = meshgrid(linspace(-6, 6, 30), linspace(-6, 6, 30));
    X_test_mat = [X1_grid(:)'; X2_grid(:)'];
    
    if strcmp(archType, 'cnn')
        % Format for Spatial CNNs: [1 x 1 x Channels x Batch]
        X = dlarray(reshape(X_mat(:, idx), 1, 1, 2, []), 'SSCB');
        Y_class = dlarray(reshape(Y_mat(:, idx), 1, 1, 2, []), 'SSCB');
        X_test = dlarray(reshape(X_test_mat, 1, 1, 2, []), 'SSCB');
    else
        % Format for MLPs: [Channels x Batch]
        X = dlarray(X_mat(:, idx), 'CB');
        Y_class = dlarray(Y_mat(:, idx), 'CB');
        X_test = dlarray(X_test_mat, 'CB');
    end
    
    % 2. NETWORK SETUP
    [encStd, decStd, clsStd] = buildBranchingNetworks(networkWidth, useDropout, dropoutProb, archType);
    [encUnsync, decUnsync, clsUnsync] = buildBranchingNetworks(networkWidth, useDropout, dropoutProb, archType);
    [encSync, decSync, clsSync] = buildBranchingNetworks(networkWidth, useDropout, dropoutProb, archType);
    
    % Copy weights perfectly
    encUnsync.Learnables = encStd.Learnables; decUnsync.Learnables = decStd.Learnables; clsUnsync.Learnables = clsStd.Learnables;
    encSync.Learnables = encStd.Learnables;   decSync.Learnables = decStd.Learnables;   clsSync.Learnables = clsStd.Learnables;
    
    % Optimizers
    velStd = {[], [], []}; velUnsync = {[], [], []}; velSync = {[], [], []};
    learnRate = 0.05; numIterations = 150;
    
    % Tracking Arrays
    lossStdHist = zeros(1, numIterations); lossUnsyncHist = zeros(1, numIterations); lossSyncHist = zeros(1, numIterations);
    gradDiffUnsyncHist = zeros(1, numIterations); gradDiffSyncHist = zeros(1, numIterations);
    lossReconHist = zeros(1, numIterations); lossClassHist = zeros(1, numIterations); lossKLHist = zeros(1, numIterations);
    
    disp('--- Starting Joint Training Loop ---');
    
    % 3. TRAINING LOOP
    for iter = 1:numIterations
        iterRngState = rng; % SYNC POINT: Ensure all methods face same dropout/sampling masks!
        
        % A. STANDARD PASS
        rng(iterRngState);
        [gEncStd, gDecStd, gClsStd, lossStd, lRecon, lClass, lKL] = dlfeval(@standardJointVAE, encStd, decStd, clsStd, X, Y_class, classWeight);
        
        % B. UNSYNCED CHECKPOINTING (Broken)
        rng(iterRngState);
        [gEncUn, gDecUn, gClsUn, lossUn] = checkpointedJointVAE_Unsynced(encUnsync, decUnsync, clsUnsync, X, Y_class, classWeight);
        
        % C. SYNCED CHECKPOINTING (Fixed)
        rng(iterRngState);
        [gEncSy, gDecSy, gClsSy, lossSy] = checkpointedJointVAE_Synced(encSync, decSync, clsSync, X, Y_class, classWeight);
        
        % D. CALCULATE GRADIENT DIFFERENCES
        diffUnsync = max([getMaxDiff(gEncStd, gEncUn), getMaxDiff(gDecStd, gDecUn), getMaxDiff(gClsStd, gClsUn)]);
        diffSync   = max([getMaxDiff(gEncStd, gEncSy), getMaxDiff(gDecStd, gDecSy), getMaxDiff(gClsStd, gClsSy)]);
        
        lossStdHist(iter) = lossStd; lossUnsyncHist(iter) = lossUn; lossSyncHist(iter) = lossSy;
        gradDiffUnsyncHist(iter) = diffUnsync; gradDiffSyncHist(iter) = diffSync;
        lossReconHist(iter) = lRecon; lossClassHist(iter) = lClass; lossKLHist(iter) = lKL;
        
        % E. UPDATES
        [encStd, velStd{1}] = sgdmupdate(encStd, gEncStd, velStd{1}, learnRate, 0.9);
        [decStd, velStd{2}] = sgdmupdate(decStd, gDecStd, velStd{2}, learnRate, 0.9);
        [clsStd, velStd{3}] = sgdmupdate(clsStd, gClsStd, velStd{3}, learnRate, 0.9);
        
        [encUnsync, velUnsync{1}] = sgdmupdate(encUnsync, gEncUn, velUnsync{1}, learnRate, 0.9);
        [decUnsync, velUnsync{2}] = sgdmupdate(decUnsync, gDecUn, velUnsync{2}, learnRate, 0.9);
        [clsUnsync, velUnsync{3}] = sgdmupdate(clsUnsync, gClsUn, velUnsync{3}, learnRate, 0.9);
        
        [encSync, velSync{1}] = sgdmupdate(encSync, gEncSy, velSync{1}, learnRate, 0.9);
        [decSync, velSync{2}] = sgdmupdate(decSync, gDecSy, velSync{2}, learnRate, 0.9);
        [clsSync, velSync{3}] = sgdmupdate(clsSync, gClsSy, velSync{3}, learnRate, 0.9);
    end
    
    visualizeBranching(lossStdHist, lossUnsyncHist, lossSyncHist, lossReconHist, lossClassHist, lossKLHist, gradDiffUnsyncHist, gradDiffSyncHist, ...
                       encStd, decStd, clsStd, encSync, decSync, clsSync, X_test, X, Y_class, useDropout);
end

function maxD = getMaxDiff(g1, g2)
    maxD = 0;
    for p = 1:size(g1, 1)
        maxD = max(maxD, max(abs(g1.Value{p} - g2.Value{p}), [], 'all'));
    end
end

function [enc, dec, cls] = buildBranchingNetworks(W, useDrop, pDrop, archType)
    % Helper functions to build layers dynamically based on archType
    function l = makeLayer(sz, name)
        if strcmp(archType, 'cnn'), l = convolution2dLayer([1 1], sz, 'Name', name);
        else, l = fullyConnectedLayer(sz, 'Name', name); end
    end
    function l = makeAct(name)
        if contains(archType, 'relu'), l = reluLayer('Name', name);
        else, l = tanhLayer('Name', name); end
    end
    
    if strcmp(archType, 'cnn'), inL = imageInputLayer([1 1 2], 'Normalization', 'none', 'Name', 'in');
    else, inL = featureInputLayer(2, 'Name', 'in'); end

    if useDrop
        enc = dlnetwork([inL; makeLayer(W,'e1'); makeAct('t1'); dropoutLayer(pDrop,'Name','d1'); makeLayer(4,'e2')]);
        dec = dlnetwork([inL; makeLayer(W,'d1'); makeAct('t2'); dropoutLayer(pDrop,'Name','d2'); makeLayer(2,'d2_out')]);
        cls = dlnetwork([inL; makeLayer(W,'c1'); makeAct('t3'); dropoutLayer(pDrop,'Name','d3'); makeLayer(2,'c2'); softmaxLayer('Name','sm')]);
    else
        enc = dlnetwork([inL; makeLayer(W,'e1'); makeAct('t1'); makeLayer(4,'e2')]);
        dec = dlnetwork([inL; makeLayer(W,'d1'); makeAct('t2'); makeLayer(2,'d2_out')]);
        cls = dlnetwork([inL; makeLayer(W,'c1'); makeAct('t3'); makeLayer(2,'c2'); softmaxLayer('Name','sm')]);
    end
end

% =========================================================================
% METHOD 1: STANDARD
% =========================================================================
function [gEnc, gDec, gCls, lossData, lossReconOut, lossClassOut, lossKLOut] = standardJointVAE(enc, dec, cls, X, Y_class, classWeight)
    encOut = forward(enc, X);
    if ndims(X) == 4 % SSCB
        mu = encOut(:, :, 1:2, :); logvar = encOut(:, :, 3:4, :);
    else % CB
        mu = encOut(1:2, :); logvar = encOut(3:4, :);
    end
    
    Z = mu + exp(0.5 * logvar) .* randn(size(mu), 'like', mu);
    X_recon = forward(dec, Z);
    Y_logits = forward(cls, Z);
    
    lossRecon = mean((X_recon - X).^2, 'all');
    lossClass = crossentropy(Y_logits, Y_class) * classWeight; % <-- WEIGHT APPLIED HERE
    
    batchSize = size(mu, ndims(mu));
    lossKL = -0.5 * sum(1 + logvar - mu.^2 - exp(logvar), 'all') / batchSize;
    
    totalLoss = lossRecon + lossClass + lossKL;
    
    [gEnc, gDec, gCls] = dlgradient(totalLoss, enc.Learnables, dec.Learnables, cls.Learnables);
    lossData = extractdata(totalLoss);
    lossReconOut = extractdata(lossRecon);
    lossClassOut = extractdata(lossClass); % Includes the weight multiplier in plot
    lossKLOut = extractdata(lossKL);
end

% =========================================================================
% METHOD 2: UNSYNCED CHECKPOINTING (BROKEN)
% =========================================================================
function [gEnc, gDec, gCls, lossData] = checkpointedJointVAE_Unsynced(enc, dec, cls, X, Y_class, classWeight)
    encOut = forward(enc, X);
    if ndims(X) == 4, mu = encOut(:, :, 1:2, :); logvar = encOut(:, :, 3:4, :);
    else, mu = encOut(1:2, :); logvar = encOut(3:4, :); end
    
    Z = mu + exp(0.5 * logvar) .* randn(size(mu), 'like', mu);
    X_recon = forward(dec, Z);
    Y_logits = forward(cls, Z);
    
    [gDec, upDec, lossRecon] = dlfeval(@decoderGradUnsync, dec, Z, X);
    [gCls, upCls, lossClass] = dlfeval(@classifierGradUnsync, cls, Z, Y_class, classWeight);
    
    upTotal = upDec + upCls; % ADDITION RULE
    [gEnc, lossData] = dlfeval(@encoderGradUnsync, enc, X, upTotal, lossRecon, lossClass);
end

function [gParams, gInput, lossRecon] = decoderGradUnsync(dec, Z, X)
    X_recon = forward(dec, Z);
    lossRecon = mean((X_recon - X).^2, 'all');
    [gParams, gInput] = dlgradient(lossRecon, dec.Learnables, Z);
    lossRecon = extractdata(lossRecon);
end

function [gParams, gInput, lossClass] = classifierGradUnsync(cls, Z, Y_class, classWeight)
    Y_logits = forward(cls, Z);
    lossClass = crossentropy(Y_logits, Y_class) * classWeight; % <-- WEIGHT APPLIED HERE
    [gParams, gInput] = dlgradient(lossClass, cls.Learnables, Z);
    lossClass = extractdata(lossClass);
end

function [gParams, lossData] = encoderGradUnsync(enc, X, upTotal, lossRecon, lossClass)
    encOut = forward(enc, X);
    if ndims(X) == 4, mu = encOut(:, :, 1:2, :); logvar = encOut(:, :, 3:4, :);
    else, mu = encOut(1:2, :); logvar = encOut(3:4, :); end
    
    Z = mu + exp(0.5 * logvar) .* randn(size(mu), 'like', mu);
    batchSize = size(mu, ndims(mu));
    lossKL = -0.5 * sum(1 + logvar - mu.^2 - exp(logvar), 'all') / batchSize;
    surrogateLoss = sum(Z .* upTotal, 'all');
    
    [gParams] = dlgradient(lossKL + surrogateLoss, enc.Learnables);
    lossData = extractdata(lossKL) + lossRecon + lossClass;
end

% =========================================================================
% METHOD 3: SYNCED CHECKPOINTING (FIXED)
% =========================================================================
function [gEnc, gDec, gCls, lossData] = checkpointedJointVAE_Synced(enc, dec, cls, X, Y_class, classWeight)
    encRng = rng;
    encOut = forward(enc, X);
    if ndims(X) == 4, mu = encOut(:, :, 1:2, :); logvar = encOut(:, :, 3:4, :);
    else, mu = encOut(1:2, :); logvar = encOut(3:4, :); end
    
    sampleRng = rng;
    Z = mu + exp(0.5 * logvar) .* randn(size(mu), 'like', mu);
    
    decRng = rng; X_recon = forward(dec, Z);
    clsRng = rng; Y_logits = forward(cls, Z);
    
    [gDec, upDec, lossRecon] = dlfeval(@decoderGradSync, dec, Z, X, decRng);
    [gCls, upCls, lossClass] = dlfeval(@classifierGradSync, cls, Z, Y_class, classWeight, clsRng);
    
    upTotal = upDec + upCls; % ADDITION RULE
    [gEnc, lossData] = dlfeval(@encoderGradSync, enc, X, upTotal, lossRecon, lossClass, encRng);
end

function [gParams, gInput, lossRecon] = decoderGradSync(dec, Z, X, savedRng)
    rng(savedRng);
    X_recon = forward(dec, Z);
    lossRecon = mean((X_recon - X).^2, 'all');
    [gParams, gInput] = dlgradient(lossRecon, dec.Learnables, Z);
    lossRecon = extractdata(lossRecon);
end

function [gParams, gInput, lossClass] = classifierGradSync(cls, Z, Y_class, classWeight, savedRng)
    rng(savedRng);
    Y_logits = forward(cls, Z);
    lossClass = crossentropy(Y_logits, Y_class) * classWeight; % <-- WEIGHT APPLIED HERE
    [gParams, gInput] = dlgradient(lossClass, cls.Learnables, Z);
    lossClass = extractdata(lossClass);
end

function [gParams, lossData] = encoderGradSync(enc, X, upTotal, lossRecon, lossClass, savedRng)
    rng(savedRng);
    encOut = forward(enc, X);
    if ndims(X) == 4, mu = encOut(:, :, 1:2, :); logvar = encOut(:, :, 3:4, :);
    else, mu = encOut(1:2, :); logvar = encOut(3:4, :); end
    
    Z = mu + exp(0.5 * logvar) .* randn(size(mu), 'like', mu);
    batchSize = size(mu, ndims(mu));
    lossKL = -0.5 * sum(1 + logvar - mu.^2 - exp(logvar), 'all') / batchSize;
    surrogateLoss = sum(Z .* upTotal, 'all');
    
    [gParams] = dlgradient(lossKL + surrogateLoss, enc.Learnables);
    lossData = extractdata(lossKL) + lossRecon + lossClass;
end

% =========================================================================
% VISUALIZATION
% =========================================================================
function visualizeBranching(lossStd, lossUn, lossSy, lossRecon, lossClass, lossKL, gUn, gSy, encStd, decStd, clsStd, encSy, decSy, clsSy, X_test, X_train, Y_train, useDrop)
    figure('Name', 'Branching VAE Checkpointing', 'Position', [50, 100, 1400, 800]);
    
    subplot(2, 3, 1);
    plot(lossStd, 'b-', 'LineWidth', 2); hold on; plot(lossUn, 'r--', 'LineWidth', 1.5); plot(lossSy, 'g:', 'LineWidth', 2.5);
    grid on; title('Total Loss'); legend('Std', 'Unsync', 'Sync');
    
    subplot(2, 3, 2);
    plot(lossRecon, 'Color', [0.850 0.325 0.098], 'LineWidth', 2); hold on;
    plot(lossClass, 'Color', [0.494 0.184 0.556], 'LineWidth', 2);
    plot(lossKL, 'Color', [0.466 0.674 0.188], 'LineWidth', 2);
    grid on; title('Individual Losses (Standard)'); legend('Reconstruction', 'Classification', 'KL Divergence');
    
    subplot(2, 3, 3);
    plot(gUn, 'r--', 'LineWidth', 1.5); hold on; plot(gSy, 'g-', 'LineWidth', 2);
    grid on; title('Max Grad Difference'); 
    if useDrop, ax = gca; ax.YAxis.Exponent = 0; else, ax = gca; ax.YAxis.Exponent = -7; end
    legend('Unsync (Broken)', 'Sync (Matches Std)');
    
    outStd = forward(encStd, X_test); outSy = forward(encSy, X_test); 
    if ndims(outStd) == 4, Z_std = outStd(:, :, 1:2, :); Z_sy = outSy(:, :, 1:2, :);
    else, Z_std = outStd(1:2, :); Z_sy = outSy(1:2, :); end
    
    X_recon_std = squeeze(extractdata(forward(decStd, Z_std))); X_recon_sy = squeeze(extractdata(forward(decSy, Z_sy)));
    [~, cls_std] = max(squeeze(extractdata(forward(clsStd, Z_std))), [], 1); [~, cls_sy] = max(squeeze(extractdata(forward(clsSy, Z_sy))), [], 1);
    X_plot = squeeze(extractdata(X_test)); X_tr = squeeze(extractdata(X_train));
    
    subplot(2, 3, 4);
    scatter(X_tr(1,:), X_tr(2,:), 15, 'k', 'filled', 'MarkerFaceAlpha', 0.1); hold on;
    scatter(X_recon_std(1,:), X_recon_std(2,:), 30, 'bo'); scatter(X_recon_sy(1,:), X_recon_sy(2,:), 30, 'rx');
    grid on; title('Decoder Branch (Recon)'); legend('Truth', 'Std', 'Sync');
    
    subplot(2, 3, 5);
    gSz = 30; X1 = reshape(X_plot(1,:), gSz, gSz); X2 = reshape(X_plot(2,:), gSz, gSz);
    contourf(X1, X2, reshape(cls_std, gSz, gSz), [1.5 1.5], 'LineColor', 'none'); colormap(gca, [0.8 0.9 1; 1 0.8 0.8]); hold on;
    contour(X1, X2, reshape(cls_sy, gSz, gSz), [1.5 1.5], 'k--', 'LineWidth', 2);
    grid on; title('Classifier Branch'); legend('Std Regions', 'Sync Line');

    subplot(2, 3, 6);
    outTr = forward(encStd, X_train); 
    if ndims(outTr) == 4, Z_tr = squeeze(extractdata(outTr(:, :, 1:2, :)));
    else, Z_tr = squeeze(extractdata(outTr(1:2, :))); end
    [~, class_tr] = max(squeeze(extractdata(Y_train)), [], 1);
    scatter(Z_tr(1, class_tr==1), Z_tr(2, class_tr==1), 20, 'b', 'filled'); hold on;
    scatter(Z_tr(1, class_tr==2), Z_tr(2, class_tr==2), 20, 'r', 'filled');
    grid on; title('Latent Space (Z)'); legend('Class 1', 'Class 2', 'Location', 'best');
end