# Fiberfiltering Dependencies

This document lists ALL files required for fiberfiltering functionality to work properly.

## Core Fiberfiltering Files (Required)

### Main Helper Functions (3 files)
- `helpers/ea_filterfiber_roi.m` - Filter fibers by ROI
- `helpers/ea_filterfiber_stim.m` - Filter fibers by stimulation
- `helpers/ea_filterfiber_len.m` - Filter fibers by length

### Fiberfiltering Explorer Directory (49 files)
- `explorers/fiberfiltering_explorer/ea_disctract.m` - Main class
- `explorers/fiberfiltering_explorer/ea_discfiberexplorer.mlapp` - Main GUI
- `explorers/fiberfiltering_explorer/ea_discfibers_calcstats.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_calcvals.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_calcvals_pam.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_calcvals_pam_prob.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_calcvals_cleartune.m`
- `explorers/fiberfiltering_explorer/ea_compute_fibscore_model.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_getvats.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_getpams.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_getlattice.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_getpeak.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_optimize.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_predict.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_loadModel_calcstats.m`
- `explorers/fiberfiltering_explorer/ea_save_fibscore_model.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_weightedLinearRegression.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_TwoSample_weightedLinearRegression.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_odds_ratios.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_vtascore.m`
- `explorers/fiberfiltering_explorer/ea_disctract_crossval.m`
- `explorers/fiberfiltering_explorer/ea_disctract_crossval_visualize.m`
- `explorers/fiberfiltering_explorer/ea_get_PCA_graphs.m`
- `explorers/fiberfiltering_explorer/ea_get_fiber_spatial_corr.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_merge_pathways.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_roi_collect.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_roi_nimage_sel.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_showroi.m`
- `explorers/fiberfiltering_explorer/ea_connectome_from_pathways.m`
- `explorers/fiberfiltering_explorer/ea_discfibers2nifti.m`
- `explorers/fiberfiltering_explorer/ea_discfibers2trk.m`
- `explorers/fiberfiltering_explorer/ea_discfibers2raw.m`
- `explorers/fiberfiltering_explorer/ea_export_symptoms_tracts.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_checkcustomNii.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_compat_statmetrics2statsettings.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_ui_enablerules.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_addjitter.m`
- `explorers/fiberfiltering_explorer/ea_add_discfiber.m`
- `explorers/fiberfiltering_explorer/ea_apply_fiber_gaussmooth.m`
- `explorers/fiberfiltering_explorer/ea_save_settings.m`
- `explorers/fiberfiltering_explorer/ea_update_settings.m`
- `explorers/fiberfiltering_explorer/ea_conn2connid.m`
- `explorers/fiberfiltering_explorer/ea_method2methodid.m`
- `explorers/fiberfiltering_explorer/ea_corrsignan.m`
- `explorers/fiberfiltering_explorer/ea_discfibers_exportatlas.mlapp`
- `explorers/fiberfiltering_explorer/ea_discfibers_refinefibercolor.mlapp`
- `explorers/fiberfiltering_explorer/native_Eproj/ea_get_Eproj.m`

## Essential Helper Functions (70+ files)

### NIfTI I/O
- `helpers/ea_load_nii.m`
- `helpers/ea_write_nii.m`
- `helpers/ea_niifileparts.m`
- `helpers/ea_niigz.m`
- `helpers/ea_detvoxsize.m`

### Coordinate Conversion
- `helpers/ea_vox2mm.m`
- `helpers/ea_mm2vox.m`
- `helpers/ea_mm2uniqueVoxInd.m`
- `helpers/ea_get_affine.m`

### Spatial Operations
- `helpers/ea_spherical_roi.m`
- `helpers/ea_autocrop.m`

### Path & Space Management
- `ea_space.m`
- `helpers/space/ea_getspace.m`
- `ea_getearoot.m`
- `helpers/ea_getconnectomebase.m`

### Statistics
- `helpers/stats/ea_resid.m`
- `ea_nanmean.m`
- `helpers/ea_color_wes.m`
- `helpers/ea_SigmoidFromEfield.m`

### GUI & File Operations
- `helpers/gui/ea_mkdir.m`
- `helpers/ea_error.m`
- `helpers/ea_warndlg.m`

### Configuration
- `ea_prefs.m`
- `common/ea_prefs_default.m`
- `common/ea_prefs_default.json`
- `common/ea_prefs_default.mat`
- `ea_defaultoptions.m`

## Statistical Test Functions (14 files)

Located in `explorers/stattests/`:
- `ea_explorer_statlist.m`
- `ea_explorer_stats_1samplettest.m`
- `ea_explorer_stats_2samplettest.m`
- `ea_explorer_stats_spearman.m`
- `ea_explorer_stats_pearson.m`
- `ea_explorer_stats_bend.m`
- `ea_explorer_stats_nmap.m`
- `ea_explorer_stats_meanmap.m`
- `ea_explorer_stats_proportiontest.m`
- `ea_explorer_stats_ranksumtest.m`
- `ea_explorer_stats_signedranktest.m`
- `ea_explorer_stats_reverse_2samplettest.m`
- `ea_explorer_stats_1sampleweightedlinreg.m`
- `ea_explorer_stats_2sampleweightedlinreg.m`

## External Dependencies

### Required Toolboxes
1. **SPM12** - Statistical Parametric Mapping
   - `spm_vol` - Read NIfTI headers
   - `spm_read_vols` - Read NIfTI volumes
   - Required for all NIfTI I/O

2. **MATLAB Statistics and Machine Learning Toolbox**
   - `fitglm` - Generalized linear models
   - `pca` - Principal component analysis
   - `corr` - Correlation functions
   - Various statistical test functions

### Additional Utilities Needed
- `GetFullPath` - Full path resolution (File Exchange or custom)
- `ea_cprintf` - Colored console output (can be replaced with fprintf)

## Files That Can Be Removed

Everything NOT listed above can potentially be removed if ONLY fiberfiltering is needed.

This includes:
- Electrode reconstruction files (ea_autocoord.m, ea_diode_*.m, etc.)
- Normalization files (ea_normalize_*.m)
- Coregistration files (ea_coreg*.m)
- VAT generation files (ea_genvat_*.m) - unless using VAT-based connectivity
- Most GUI files (lead.fig, lead_group.fig, etc.)
- Lead Mapper/Group/Predict GUIs
- Clinical scoring files
- Genetics files
- Cluster computing files
- Database hub files

## Minimal Core for Basic Fiber Filtering Only

If you ONLY need the three basic filter functions (roi, stim, len):
- 3 main filter files
- ~20 helper files for NIfTI I/O and coordinate conversion
- SPM12 dependency
- Total: ~25 files

## Full Fiberfiltering Explorer

For complete fiberfiltering explorer with statistics and GUI:
- ~110 files total
- SPM12 dependency
- MATLAB Statistics Toolbox dependency
