# Directory Reorganization Plan

## Current Issues

1. **217 MATLAB files in root directory** - Industry best practice is minimal root files
2. **Inconsistent naming** - Mix of ea_ prefix, camelCase, and underscore_case
3. **No package structure** - MATLAB packages (+packagename) not used
4. **Poor separation of concerns** - Mixed functionality at root level
5. **No clear API boundary** - Public vs private functions not distinguished
6. **Tests not integrated** - Should be parallel to source structure
7. **Documentation scattered** - No centralized docs/ folder
8. **Config files mixed** - Should be in dedicated config/ folder

## MATLAB Industry Best Practices

### 1. Directory Structure
```
project_root/
├── +fiberfiltering/        % Main package (MATLAB namespace)
│   ├── +core/              % Core algorithms
│   ├── +io/                % Input/output operations
│   ├── +utils/             % Utilities
│   ├── +stats/             % Statistical functions
│   └── +viz/               % Visualization
├── src/                    % Non-packaged source (if needed)
├── test/                   % Unit tests (mirror src structure)
├── examples/               % Example scripts and demos
├── docs/                   % Documentation
├── config/                 % Configuration files
├── data/                   % Sample/test data (if small)
├── external/               % Third-party dependencies
└── resources/              % Assets, templates, etc.
```

### 2. Root Level Files (Minimal)
- `startup.m` - Path setup and initialization
- `README.md` - Project overview
- `LICENSE.md` - License information
- `CHANGELOG.md` - Version history
- `.gitignore` - Git configuration

### 3. Naming Conventions
- **Packages**: lowercase with + prefix (`+fiberfiltering`)
- **Classes**: PascalCase (`FiberFilter`)
- **Functions**: camelCase (`filterFibersByROI`)
- **Constants**: UPPER_CASE (`MAX_FIBER_LENGTH`)
- **Private functions**: In private/ subdirectories

### 4. Package Benefits
- Namespace protection
- Cleaner API
- Better organization
- IDE-friendly
- Easier dependency management

## Proposed New Structure

```
fiberfiltering/
├── +fiberfiltering/                    % Main MATLAB package
│   ├── +core/                          % Core filtering algorithms
│   │   ├── filterByROI.m
│   │   ├── filterByStimulation.m
│   │   ├── filterByLength.m
│   │   └── FiberFilter.m               % Main class
│   ├── +io/                            % Input/output
│   │   ├── loadNifti.m
│   │   ├── writeNifti.m
│   │   ├── loadFibers.m
│   │   ├── saveFibers.m
│   │   └── +nifti/                     % NIfTI-specific
│   ├── +spatial/                       % Spatial operations
│   │   ├── voxelToMM.m
│   │   ├── mmToVoxel.m
│   │   ├── createSphericalROI.m
│   │   └── transformCoordinates.m
│   ├── +stats/                         % Statistical analysis
│   │   ├── computeStats.m
│   │   ├── runTTest.m
│   │   ├── runCorrelation.m
│   │   └── crossValidate.m
│   ├── +models/                        % VAT and connectivity models
│   │   ├── kuncleModel.m
│   │   ├── maedlerModel.m
│   │   └── computeConnectivity.m
│   ├── +utils/                         % General utilities
│   │   ├── validateInputs.m
│   │   ├── setupPaths.m
│   │   └── errorHandling.m
│   └── +viz/                           % Visualization (if kept)
│       └── plotFibers.m
├── src/                                % Non-packaged sources
│   ├── gui/                            % GUI applications
│   │   └── FiberFilteringExplorer.mlapp
│   ├── legacy/                         % Legacy code (to be refactored)
│   │   └── ea_*.m                      % Original ea_ prefixed files
│   └── classes/                        % Additional classes
│       └── DiscrTract.m
├── test/                               % Unit tests
│   ├── +core/
│   │   ├── testFilterByROI.m
│   │   ├── testFilterByStimulation.m
│   │   └── testFilterByLength.m
│   ├── +io/
│   │   └── testNiftiIO.m
│   ├── +spatial/
│   │   └── testCoordinateConversion.m
│   └── runAllTests.m
├── examples/                           % Examples and demos
│   ├── quickstart.m
│   ├── basic_filtering.m
│   ├── advanced_analysis.m
│   └── data/                           % Example data
├── docs/                               % Documentation
│   ├── user_guide.md
│   ├── api_reference.md
│   ├── developer_guide.md
│   ├── installation.md
│   └── images/
├── config/                             % Configuration
│   ├── default_prefs.json
│   ├── default_prefs.mat
│   └── templates/
├── external/                           % External dependencies
│   ├── spm12/                          % SPM (if bundled)
│   └── other_toolboxes/
├── resources/                          % Non-code resources
│   └── templates/
├── scripts/                            % Utility scripts
│   ├── setup_environment.m
│   ├── run_tests.m
│   └── build_documentation.m
├── .github/                            % GitHub configuration
│   └── workflows/
├── startup.m                           % Project initialization
├── README.md                           % Main readme
├── LICENSE.md                          % License
├── CHANGELOG.md                        % Version history
├── CONTRIBUTING.md                     % Contribution guidelines
├── .gitignore                          % Git ignore
└── version.txt                         % Version file
```

## Migration Strategy

### Phase 1: Create New Structure
1. Create package directories (+fiberfiltering/+core/, etc.)
2. Create non-package directories (test/, docs/, etc.)
3. Preserve original structure temporarily

### Phase 2: Categorize and Move Files
1. **Core filtering functions** → +fiberfiltering/+core/
2. **I/O functions** → +fiberfiltering/+io/
3. **Spatial operations** → +fiberfiltering/+spatial/
4. **Statistical functions** → +fiberfiltering/+stats/
5. **Helper utilities** → +fiberfiltering/+utils/
6. **GUI applications** → src/gui/
7. **Test files** → test/ (mirroring package structure)
8. **Documentation** → docs/
9. **Config files** → config/

### Phase 3: Refactor Function Names
Remove `ea_` prefix and use camelCase:
- `ea_filterfiber_roi.m` → `filterByROI.m`
- `ea_load_nii.m` → `loadNifti.m`
- `ea_vox2mm.m` → `voxelToMM.m`

### Phase 4: Update Dependencies
1. Create path setup in startup.m
2. Update function calls to use package notation
3. Update imports and dependencies

### Phase 5: Create API Layer
Create high-level API functions:
```matlab
% In +fiberfiltering/filterFibers.m
function result = filterFibers(fibers, varargin)
    % High-level interface to all filtering operations
    % Dispatches to appropriate core functions
end
```

## Benefits of Reorganization

1. **Professionalism**: Matches industry standards
2. **Maintainability**: Clear organization makes code easier to maintain
3. **Scalability**: Easy to add new features in logical places
4. **Collaboration**: Team members can navigate easily
5. **Documentation**: Clear structure for docs and examples
6. **Testing**: Tests mirror source structure
7. **IDE Support**: Better autocomplete and navigation
8. **Namespace**: Avoids name conflicts

## Backward Compatibility

To maintain compatibility during transition:
1. Keep legacy/ folder with wrapper functions
2. Legacy functions call new package functions
3. Deprecation warnings guide users to new API
4. Document migration path

## Implementation Priority

1. **High Priority** (Core functionality)
   - Core filtering functions
   - I/O operations
   - Coordinate conversions

2. **Medium Priority** (Important but not critical)
   - Statistical functions
   - Test reorganization
   - Documentation structure

3. **Low Priority** (Nice to have)
   - GUI reorganization
   - Advanced visualization
   - Example scripts

## Breaking Changes

Users will need to:
1. Update function calls from `ea_*` to `fiberfiltering.*`
2. Update paths in their scripts
3. Use new startup.m for initialization

However, legacy wrappers can minimize disruption.
