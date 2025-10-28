# Fiberfiltering Toolbox

A professional MATLAB toolbox for filtering and analyzing white matter fiber tractography data, extracted from LEAD-DBS.

[![MATLAB](https://img.shields.io/badge/MATLAB-R2022b+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/license-See%20LICENSE-green.svg)](LICENSE.md)
[![Version](https://img.shields.io/badge/version-2.0.0--beta-orange.svg)](version.txt)

## Overview

The Fiberfiltering Toolbox provides robust tools for filtering fiber tractography data based on various criteria:

- **ROI-based filtering**: Keep only fibers passing through regions of interest
- **Stimulation-based filtering**: Filter based on electrode contacts and stimulation parameters
- **Length-based filtering**: Remove fibers below a length threshold
- **Statistical analysis**: Correlate fiber connectivity with clinical outcomes
- **Cross-validation**: Assess predictive models
- **Visualization**: Interactive 3D fiber tract visualization

## Features

✓ **Industry-standard structure**: MATLAB package (+fiberfiltering) organization
✓ **Clean API**: High-level unified interface and low-level core functions
✓ **Comprehensive testing**: Unit tests for all core functionality
✓ **Well documented**: Inline help, examples, and user guides
✓ **Modular design**: Separation of concerns with clear dependencies
✓ **Professional practices**: Follows MATLAB style guidelines

## Quick Start

### Installation

1. **Clone or download** this repository
2. **Navigate** to the toolbox root directory in MATLAB
3. **Run** the startup script:

```matlab
startup
```

This will configure paths and check dependencies.

### Basic Usage

```matlab
% High-level API
filtered = fiberfiltering.filterFibers(fibers, ...
    'Method', 'roi', ...
    'ROI', 'path/to/roi.nii');

% Or use core functions directly
filtered = fiberfiltering.core.filterByROI(fibers, 'roi.nii');
filtered = fiberfiltering.core.filterByLength(fibers, 10);
```

See `examples/quickstart.m` for more examples.

## Directory Structure

```
fiberfiltering/
├── +fiberfiltering/          # Main MATLAB package
│   ├── +core/                # Core filtering algorithms
│   ├── +io/                  # Input/output operations
│   ├── +spatial/             # Spatial coordinate operations
│   ├── +stats/               # Statistical analysis
│   ├── +models/              # VAT and connectivity models
│   ├── +utils/               # Utilities
│   └── filterFibers.m        # High-level API
├── src/                      # Additional source code
│   ├── gui/                  # GUI applications (.mlapp files)
│   ├── legacy/               # Legacy code (backward compatibility)
│   └── classes/              # Additional class definitions
├── test/                     # Unit tests (mirrors package structure)
├── examples/                 # Example scripts and demos
├── docs/                     # Documentation
├── config/                   # Configuration files
├── scripts/                  # Utility scripts
├── helpers/                  # Legacy helper functions
├── external/                 # External dependencies
├── resources/                # Templates and assets
├── startup.m                 # Environment initialization
└── README.md                 # This file
```

## Requirements

### MATLAB

- **Version**: R2022b or later
- **Toolboxes**:
  - Image Processing Toolbox (required)
  - Statistics and Machine Learning Toolbox (required)
  - Signal Processing Toolbox (optional)

### External Dependencies

- **SPM12** (required): Statistical Parametric Mapping
  - Download: https://www.fil.ion.ucl.ac.uk/spm/software/download/
  - Used for NIfTI file I/O operations

## Documentation

- **User Guide**: [`docs/README.md`](docs/README.md)
- **API Reference**: Use `help +fiberfiltering` in MATLAB
- **Examples**: See `examples/` directory
- **Dependencies**: [`docs/dependencies.md`](docs/dependencies.md)

## Core Functions

### Package API

```matlab
% Main unified interface
fiberfiltering.filterFibers(...)

% Core filtering functions
fiberfiltering.core.filterByROI(fibers, roi, [output])
fiberfiltering.core.filterByStimulation(fibers, coords, stim, model, factor)
fiberfiltering.core.filterByLength(fibers, minLength)

% I/O operations
fiberfiltering.io.loadNifti(filepath)
fiberfiltering.io.writeNifti(nifti, filepath)

% Spatial operations
fiberfiltering.spatial.voxelToMM(coords, affine)
fiberfiltering.spatial.mmToVoxel(coords, affine)
fiberfiltering.spatial.createSphericalROI(center, radius, template)
```

### Legacy Functions (Backward Compatibility)

Original `ea_*` prefixed functions are preserved in `helpers/` for backward compatibility.

## Examples

### Example 1: Filter by ROI

```matlab
% Load fiber data
fibers = load('connectome.mat');

% Filter by ROI
filtered = fiberfiltering.core.filterByROI(fibers, 'striatum_roi.nii');

% Save results
save('filtered_fibers.mat', '-struct', 'filtered');
```

### Example 2: Filter by Length

```matlab
% Remove short fibers (< 10mm)
minLength = 10;  % mm
filtered = fiberfiltering.core.filterByLength(fibers, minLength);
```

### Example 3: Filter by Stimulation

```matlab
% Define electrode contacts
coords = {[0,0,0; 0,0,3; 0,0,6; 0,0,9], []};  % Right hemisphere

% Define stimulation (3V on contact 1)
stimVector = [3.0, 0, 0, 0; 0, 0, 0, 0];

% Filter using Kuncel model
filtered = fiberfiltering.core.filterByStimulation(...
    fibers, coords, stimVector, 'kuncel', 1);
```

## Testing

Run the test suite:

```matlab
% From root directory
cd test
run_all_tests
```

Or run individual tests:

```matlab
test.core.testFilterByROI
test.core.testFilterByLength
test.core.testFilterByStimulation
```

## GUI Application

Launch the Fiberfiltering Explorer GUI:

```matlab
% Open the GUI
open src/gui/ea_discfiberexplorer.mlapp
```

## Development

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Follow MATLAB style guidelines
5. Submit a pull request

### Project Structure Best Practices

This project follows MATLAB industry best practices:

- **Package structure** (+packagename) for namespace management
- **Modular design** with clear separation of concerns
- **Comprehensive testing** with tests mirroring source structure
- **Professional documentation** with inline help and guides
- **Clean API boundaries** between public and private functions

See [`docs/reorganization_plan.md`](docs/reorganization_plan.md) for details.

## Version History

- **2.0.0-beta** (2025-10-27): Major reorganization following industry best practices
  - Introduced MATLAB package structure
  - Created high-level unified API
  - Reorganized directory structure
  - Enhanced documentation

- **1.0.0**: Initial stripped version (fiberfiltering only from LEAD-DBS)

See [`CHANGELOG.md`](CHANGELOG.md) for detailed history.

## Citation

If you use this toolbox, please cite:

```bibtex
@software{fiberfiltering2025,
  title={Fiberfiltering Toolbox},
  author={LEAD-DBS Development Team},
  year={2025},
  url={https://github.com/your-repo/fiberfiltering}
}
```

Original LEAD-DBS citations in [`CITATION.cff`](CITATION.cff).

## License

See [`LICENSE.md`](LICENSE.md) for license information.

## Support

- **Issues**: Report bugs and request features via GitHub Issues
- **Documentation**: See `docs/` directory
- **Examples**: See `examples/` directory
- **Original LEAD-DBS**: https://www.lead-dbs.org

## Acknowledgments

This toolbox is extracted and refactored from the LEAD-DBS project:
- Original LEAD-DBS: https://www.lead-dbs.org
- LEAD-DBS GitHub: https://github.com/netstim/leaddbs

## Contact

For questions about this toolbox:
- Open an issue on GitHub
- Consult the documentation in `docs/`
- Refer to LEAD-DBS resources for background information

---

**Note**: This is version 2.0.0-beta with major structural improvements. The API is stable but further optimizations may be made before the final 2.0.0 release.
