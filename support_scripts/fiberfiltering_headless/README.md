# Headless Fiber Filtering Scripts

This directory contains standalone scripts for running Lead-DBS fiber filtering analyses without the GUI.

## Quick Start

### 1. Basic Analysis

```matlab
% Run fiber filtering analysis
obj = fibfilt_run_analysis('/path/to/leadgroup.mat', 'MyConnectome', ...
    'connectivity_type', 1, ...
    'statmetric', 'Correlations / E-fields (Irmen 2020)');
```

### 2. Cross-Validation

```matlab
% Run k-fold cross-validation
[I, Ihat, stats] = fibfilt_run_crossval('/path/to/results.fibfilt', 'kfold', ...
    'kfold', 5);

fprintf('Correlation: R=%.4f, p=%.4f\n', stats.r, stats.p);
```

### 3. Export Results

```matlab
% Export to NIfTI and TRK formats
fibfilt_export_results('/path/to/results.fibfilt', ...
    'threshold', 0.05, ...
    'fiberset', 'both');
```

## Scripts

- **fibfilt_run_analysis.m** - Main entry point for running fiber filtering
- **fibfilt_run_crossval.m** - Cross-validation (LOO, LOCO, k-fold, LNO)
- **fibfilt_export_results.m** - Export to various formats
- **fibfilt_batch_example.m** - Template for batch processing

## Parameters

### fibfilt_run_analysis.m

**Required:**
- `leadgroup_path` - Path to Lead Group .mat file
- `connectome_name` - Name of dMRI connectome

**Optional:**
- `connectivity_type` - 1 (VAT, default) or 2 (PAM)
- `statmetric` - Statistical test (see list below)
- `native` - Calculate in native (1) or template (0) space (default: 1)
- `patientselection` - Patient indices to include (default: all)
- `responsevar_idx` - Clinical variable index (default: 1)
- `covars_idx` - Covariate indices (default: [])
- `calcthreshold` - Calculation threshold (default: 0.05)
- `corrtype` - 'Spearman' or 'Pearson' (default: 'Spearman')
- `silent` - Suppress console output (default: false)
- `save_results` - Save .fibfilt file (default: true)
- `output_dir` - Output directory (default: leadgroup directory)

### fibfilt_run_crossval.m

**Required:**
- `fibfilt_path` - Path to .fibfilt file
- `cv_type` - Cross-validation type

**Optional:**
- `kfold` - Number of folds for k-fold CV (default: 5)
- `kIter` - Number of iterations for k-fold (default: 1)
- `silent` - Suppress output (default: false)
- `save_results` - Save CV results (default: true)

### fibfilt_export_results.m

**Required:**
- `fibfilt_path` - Path to .fibfilt file

**Optional:**
- `export_nifti` - Export to NIfTI (default: true)
- `export_trk` - Export to TRK (default: true)
- `export_model` - Export fiber score model (default: true)
- `threshold` - Fiber selection threshold (default: 0.05)
- `fiberset` - 'positive', 'negative', or 'both' (default: 'both')
- `output_dir` - Output directory (default: same as .fibfilt)
- `silent` - Suppress output (default: false)

## Statistical Metrics

Available options for `statmetric` parameter:

- `'Two-Sample T-Tests / VTAs (Baldermann 2019) / PAM (OSS-DBS)'`
- `'Correlations / E-fields (Irmen 2020)'`
- `'Proportion Test (Chi-Square) / VTAs (binary vars)'`
- `'Binomial Tests / VTAs (binary vars)'`
- `'Reverse T-Tests / E-Fields (binary vars)'`
- `'Plain Connections'`
- `'Odds Ratios / EF-Sigmoid (Jergas 2023)'`
- `'Weighted Linear Regression / EF-Sigmoid (Dembek 2023)'`

## Cross-Validation Types

- `'loocv'` - Leave-One-Out Cross-Validation
- `'lococv'` - Leave-One-Cohort-Out Cross-Validation
- `'kfold'` - K-Fold Cross-Validation (specify k with 'kfold' parameter)
- `'lno'` - Leave-Nothing-Out (resubstitution)

## Requirements

- Lead-DBS properly installed and on MATLAB path
- Lead Group project with clinical variables
- Connectome data available
- For PAM: Biophysical simulations must be pre-computed

## Complete Workflow Example

```matlab
% 1. Run fiber filtering analysis
obj = fibfilt_run_analysis(...
    '/path/to/leadgroup.mat', ...
    'HCP_MGH_32fold_100k', ...
    'connectivity_type', 1, ...
    'statmetric', 'Correlations / E-fields (Irmen 2020)', ...
    'responsevar_idx', 1, ...
    'covars_idx', [2, 3]);

% 2. Run cross-validation
fibfilt_path = fullfile(fileparts('/path/to/leadgroup.mat'), ...
                        'fiberfiltering', [obj.ID, '.fibfilt']);
[I, Ihat, stats] = fibfilt_run_crossval(fibfilt_path, 'kfold', ...
    'kfold', 5);

% 3. Export results
fibfilt_export_results(fibfilt_path, ...
    'export_nifti', true, ...
    'export_trk', true, ...
    'export_model', true);
```

## Batch Processing

See `fibfilt_batch_example.m` for a complete batch processing workflow that:
- Processes multiple Lead Group projects
- Runs analysis → cross-validation → export for each
- Handles errors gracefully
- Provides summary statistics

## Advanced Usage

### Direct ea_disctract Usage

For more control, you can use the `ea_disctract` class directly in headless mode:

```matlab
% Create headless tractset object
obj = ea_disctract();
obj.headless = true;
obj.silent = false;

% Initialize with Lead Group
obj.initialize('/path/to/leadgroup.mat', []);

% Configure analysis
obj.connectome = 'MyConnectome';
obj.connectivity_type = 1;
obj.native = 1;
obj.patientselection = 1:length(obj.M.patient.list);
obj.responsevar = obj.M.clinical.vars{1};

% Run calculation
obj.calculate();

% Run cross-validation
[I, Ihat] = obj.loocv();

% Save
obj.save();
```

## Notes

- All scripts run without opening any GUI windows
- Progress is printed to console unless `silent=true`
- Results are automatically saved unless `save_results=false`
- The `ea_disctract` class still works in GUI mode when `headless=false` (default)
- All visualization is disabled in headless mode for maximum performance

## Troubleshooting

**Error: "PAM files not found"**
- Make sure biophysical simulations are computed before running with `connectivity_type=2`

**Error: "Stimulation volumes not found"**
- Ensure VATs/E-fields are calculated before running fiber filtering

**Error: "Connectome not found"**
- Verify the connectome name and that the data exists in the connectome database

## Support

For issues or questions, please refer to the main Lead-DBS documentation or file an issue in the Lead-DBS repository.
