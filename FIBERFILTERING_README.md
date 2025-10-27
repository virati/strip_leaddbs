# LEAD-DBS Fiberfiltering Module (Stripped Version)

This is a stripped-down version of LEAD-DBS containing **only** the fiberfiltering functionality.

## What Was Done

This repository has been systematically cleaned to remove all non-essential components, keeping only what's needed for fiber filtering operations.

### Cleanup Statistics

- **Files Removed**: 81 files/directories
- **Original MATLAB files**: ~986
- **Remaining MATLAB files**: 821
- **Remaining .mlapp files**: 14
- **Disk Usage**: 110M

### What Was Removed

1. **Electrode Reconstruction** (29 files)
   - All `ea_diode_*` files
   - `ea_autocoord.m`, `ea_manualreconstruction.m`
   - Electrode segmentation and trajectory files

2. **Normalization** (21 files)
   - All `ea_normalize_*` files
   - Normalization settings GUIs

3. **Coregistration** (26 files)
   - All `ea_coreg*` files
   - Coregistration visualization tools

4. **VAT Generation** (14 files)
   - All `ea_genvat_*` files
   - VAT settings GUIs

5. **Main GUIs** (10 files)
   - `lead.m`, `lead_group.m`, `lead_predict.m`
   - `lead_anatomy.m`, `lead_demo.m`
   - All associated .fig and .mlapp files

6. **Other Explorers** (3 directories)
   - navigator/
   - sweetspot_explorer/
   - networkmapping_explorer/

7. **Entire Directories**
   - clinical/
   - genetics/
   - cluster/
   - dbshub/
   - predict/ (~25M)
   - programmer/
   - programmergroup/
   - dependency/
   - dev/ (~4.4M)
   - vatmodel/
   - ls/
   - icons/

## What Was Preserved

### Core Fiberfiltering Functions (3 files)
```
helpers/ea_filterfiber_roi.m     - Filter fibers by ROI intersection
helpers/ea_filterfiber_stim.m    - Filter fibers by stimulation parameters
helpers/ea_filterfiber_len.m     - Filter fibers by length threshold
```

### Fiberfiltering Explorer (49 files)
```
explorers/fiberfiltering_explorer/
├── ea_discfiberexplorer.mlapp           - Main GUI application
├── ea_disctract.m                        - Main discriminative fiber class
├── ea_discfibers_calcstats.m            - Statistical calculations
├── ea_discfibers_calcvals*.m            - Value calculations (VAT/PAM/etc)
├── ea_compute_fibscore_model.m          - Fiber score modeling
├── ea_discfibers_get*.m                 - Data retrieval functions
├── ea_discfibers_optimize.m             - Optimization routines
├── ea_discfibers_predict.m              - Prediction functions
├── ea_disctract_crossval*.m             - Cross-validation
├── ea_discfibers_merge_pathways.m       - Pathway management
├── ea_discfibers2*.m                    - Export/conversion functions
└── ... (and more)
```

### Statistical Tests (14 files)
```
explorers/stattests/
├── ea_explorer_statlist.m
├── ea_explorer_stats_1samplettest.m
├── ea_explorer_stats_2samplettest.m
├── ea_explorer_stats_spearman.m
├── ea_explorer_stats_pearson.m
├── ea_explorer_stats_bend.m
└── ... (and more)
```

### Essential Helper Functions (~100+ files)
```
helpers/
├── ea_load_nii.m, ea_write_nii.m        - NIfTI I/O
├── ea_vox2mm.m, ea_mm2vox.m             - Coordinate conversion
├── ea_spherical_roi.m                    - ROI generation
├── stats/ea_resid.m                      - Statistics helpers
├── gui/ea_mkdir.m                        - GUI utilities
└── ... (and more)
```

### Tests (4 files)
```
tests/fiberfiltering/
├── run_all_tests.m                      - Test runner
├── test_ea_filterfiber_roi.m            - ROI filter tests
├── test_ea_filterfiber_stim.m           - Stimulation filter tests
└── test_ea_filterfiber_len.m            - Length filter tests
```

### Configuration
```
common/ea_prefs_default.m
common/ea_prefs_default.json
common/ea_prefs_default.mat
ea_space.m
ea_getearoot.m
ea_prefs.m
ea_defaultoptions.m
```

## Functionality

This stripped version supports:

### 1. Basic Fiber Filtering
- **ROI-based filtering**: Keep only fibers passing through specified ROIs
- **Stimulation-based filtering**: Filter based on VAT models (Kuncel, Maedler)
- **Length-based filtering**: Remove fibers below length threshold

### 2. Discriminative Fiber Analysis
- Statistical analysis of fiber-symptom relationships
- Multiple statistical methods:
  - T-tests (1-sample, 2-sample)
  - Correlations (Spearman, Pearson, Bend)
  - Weighted linear regression
  - Proportion tests
  - Rank-sum tests
- Cross-validation and prediction
- PCA analysis
- Model optimization

### 3. Connectivity Calculation Methods
- **E-field/Voxel Based**: Traditional VTA-based connectivity
- **Fiber Based**: Native space E-field projection
- **PAM (Pathway Activation Model)**: Biophysical activation modeling

### 4. Visualization
- 3D fiber tract visualization
- Interactive thresholding
- Color-coding by statistical values
- ROI/VTA display

### 5. Export/Import
- NIfTI format conversion
- TRK format export
- Fiber score model saving/loading
- Symptom-tract export

## Dependencies

### Required
1. **MATLAB** R2022b or later
2. **MATLAB Toolboxes**:
   - Image Processing Toolbox
   - Signal Processing Toolbox
   - Statistics and Machine Learning Toolbox
   - (Optional) Curve Fitting Toolbox
   - (Optional) Parallel Computing Toolbox

3. **SPM12**: Required for NIfTI file I/O
   - Download from: https://www.fil.ion.ucl.ac.uk/spm/software/download/
   - Add to MATLAB path

### Data Requirements
- **Connectome files**: Fiber tractography data (.mat format with `fibers` and `idx` fields)
- **Template space**: MNI space definition files
- **ROI/VAT files**: NIfTI format stimulation volumes or regions of interest
- **Clinical data**: Response variables and covariates (optional)

## Usage

### Running Tests

```matlab
% Navigate to test directory
cd tests/fiberfiltering

% Run all tests
run_all_tests()
```

**Note**: Tests require MATLAB and cannot run in this environment. You'll need to run them in a MATLAB installation with SPM12 configured.

### Basic Fiber Filtering Example

```matlab
% Filter fibers by ROI
fiberFiltered = ea_filterfiber_roi('fibers.mat', 'roi.nii');

% Filter fibers by length (minimum 10mm)
fiberFiltered = ea_filterfiber_len(ftr, 10);

% Filter fibers by stimulation
coords = {[0,0,0; 0,0,3; 0,0,6; 0,0,9], []}; % Contact coordinates
stimVector = [3.0, 0, 0, 0; 0, 0, 0, 0];     % Stimulation parameters
fiberFiltered = ea_filterfiber_stim(ftr, coords, stimVector, 'kuncel', 1);
```

### Fiberfiltering Explorer Example

```matlab
% From support_scripts/explorer_tools_scripting/sweetspot_fiberfiltering_networkmapping_example.m

% Create figure
resultfig = ea_mnifigure;

% Setup analysis data structure
M.pseudoM = 1;
M.ROI.list = {'/path/to/roi1.nii', '/path/to/roi2.nii', ...};
M.ROI.group = ones(length(M.ROI.list), 1);
M.clinical.labels = {'Improvement'};
M.clinical.vars{1} = [1, 2, 3, 4, 5, 6, 7]; % Clinical scores
M.guid = 'My_Analysis';

% Save and open explorer
save('Analysis_Input_Data.mat', 'M');
ea_discfiberexplorer('Analysis_Input_Data.mat', resultfig);
```

## File Structure

```
strip_leaddbs/
├── helpers/
│   ├── ea_filterfiber_*.m          # Core filtering functions
│   ├── ea_load_nii.m, ea_write_nii.m
│   ├── ea_vox2mm.m, ea_mm2vox.m
│   ├── stats/
│   ├── gui/
│   └── space/
├── explorers/
│   ├── fiberfiltering_explorer/     # Main fiberfiltering module
│   └── stattests/                   # Statistical test functions
├── tests/
│   └── fiberfiltering/              # Test suite
├── common/                          # Configuration files
├── connectomics/                    # Some connectivity tools
├── classes/                         # Class definitions
├── toolbox/                         # External toolboxes
├── support_scripts/
│   └── explorer_tools_scripting/    # Example scripts
├── cleanup_analysis/                # Cleanup documentation
├── FIBERFILTERING_DEPENDENCIES.md   # Detailed dependency list
├── FIBERFILTERING_README.md         # This file
└── README.md                        # Original LEAD-DBS README
```

## Testing

Comprehensive unit tests have been created for all three core filtering functions:

- **test_ea_filterfiber_roi.m**: 4 test cases
  - Basic ROI filtering
  - Empty fiber handling
  - Struct input/output
  - Fiber index renumbering

- **test_ea_filterfiber_len.m**: 7 test cases
  - Basic length filtering
  - All fibers too short/long
  - Empty input handling
  - Cell array input
  - Precise length calculation
  - Multi-segment fibers

- **test_ea_filterfiber_stim.m**: 7 test cases
  - Kuncel VAT model
  - Maedler VAT model
  - No stimulation handling
  - Radius scaling factor
  - Multiple active contacts
  - Bilateral stimulation
  - Equation validation

## Known Limitations

1. **No MATLAB/Octave in environment**: Tests cannot be run automatically
2. **SPM12 required**: Must be installed and configured separately
3. **Data files not included**: You need to provide your own connectome and ROI data
4. **Some dependencies may remain**: Further analysis needed to identify all helper functions actually used

## Further Cleanup Potential

Additional files could potentially be removed after thorough dependency analysis:
- Some files in `classes/` directory
- Some files in `toolbox/` directory
- Some files in `connectomics/` directory
- Additional helper functions that are actually unused

A more aggressive cleanup would require:
1. Static code analysis to trace all function calls
2. Running actual fiberfiltering workflows to identify runtime dependencies
3. Testing with real data to ensure nothing breaks

## Documentation

- `FIBERFILTERING_DEPENDENCIES.md` - Complete list of required files
- `cleanup_analysis/` - Detailed analysis of removed files
- Original LEAD-DBS docs: https://www.lead-dbs.org

## Support

For questions about fiberfiltering functionality:
- LEAD-DBS website: https://www.lead-dbs.org
- Forum: https://www.lead-dbs.org/?forum=lead-dbs-support-forum
- Slack workspace: https://leadsuite.slack.com/

## Citation

If you use this fiberfiltering module, please cite:
- Original LEAD-DBS paper(s) - see CITATION.cff
- Relevant fiberfiltering methods papers

## License

See LICENSE.md (inherited from LEAD-DBS)
