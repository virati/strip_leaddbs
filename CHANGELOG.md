# Changelog

All notable changes to the Fiberfiltering Toolbox will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0-beta] - 2025-10-27

### Added - Major Reorganization

#### Package Structure
- Introduced MATLAB package structure (+fiberfiltering) for namespace management
- Created modular subpackages: +core, +io, +spatial, +stats, +models, +utils, +viz
- Implemented professional directory organization following industry best practices

#### API Improvements
- Added high-level unified API: `fiberfiltering.filterFibers()`
- Created consistent naming conventions (camelCase instead of underscore_case)
- Removed `ea_` prefix from package functions for cleaner namespace
- Maintained backward compatibility through legacy helpers

#### Documentation
- New comprehensive README.md with badges and quick start
- Created docs/ directory with organized documentation
- Added reorganization_plan.md documenting the restructuring
- Moved all markdown docs to docs/ directory
- Added inline help for all package functions

#### Examples and Testing
- Created examples/ directory with quickstart.m
- Reorganized tests to mirror package structure
- Added scripts/run_tests.m for easy test execution
- Created example data directory structure

#### Project Organization
- Added startup.m for environment initialization and path setup
- Created config/ directory for configuration files
- Added scripts/ directory for utility scripts
- Created resources/ and external/ directories
- Added .github/ for CI/CD workflows
- Created version.txt for version tracking

#### Developer Experience
- Clean separation between public API (+fiberfiltering) and internal code (src/)
- Legacy code preserved in src/legacy/ for backward compatibility
- GUI applications organized in src/gui/
- Professional project structure matching industry standards

### Changed

#### File Organization
- Moved 217 root-level MATLAB files to appropriate package subdirectories
- Reorganized core filter functions:
  - `ea_filterfiber_roi.m` → `+fiberfiltering/+core/filterByROI.m`
  - `ea_filterfiber_stim.m` → `+fiberfiltering/+core/filterByStimulation.m`
  - `ea_filterfiber_len.m` → `+fiberfiltering/+core/filterByLength.m`

- Reorganized I/O functions:
  - `ea_load_nii.m` → `+fiberfiltering/+io/loadNifti.m`
  - `ea_write_nii.m` → `+fiberfiltering/+io/writeNifti.m`
  - `ea_niifileparts.m` → `+fiberfiltering/+io/parseNiftiPath.m`

- Reorganized spatial functions:
  - `ea_vox2mm.m` → `+fiberfiltering/+spatial/voxelToMM.m`
  - `ea_mm2vox.m` → `+fiberfiltering/+spatial/mmToVoxel.m`
  - `ea_spherical_roi.m` → `+fiberfiltering/+spatial/createSphericalROI.m`

- Moved GUI applications to src/gui/
- Moved statistical tests to +fiberfiltering/+stats/tests/
- Moved configuration files to config/
- Moved documentation to docs/

#### API Changes
- New package-based API requires `fiberfiltering.` prefix
- Function names changed to camelCase (e.g., `filterByROI` instead of `ea_filterfiber_roi`)
- High-level API provides unified interface with name-value pairs
- Legacy functions remain available in helpers/ for backward compatibility

### Deprecated
- Direct use of `ea_*` prefixed functions (use package API instead)
- Root-level function calls (use fiberfiltering.* namespace)

### Migration Guide
Users migrating from v1.0.0 should:
1. Run `startup.m` to configure paths
2. Update function calls to use package notation:
   ```matlab
   % Old:
   filtered = ea_filterfiber_roi(fibers, 'roi.nii');

   % New:
   filtered = fiberfiltering.core.filterByROI(fibers, 'roi.nii');

   % Or use high-level API:
   filtered = fiberfiltering.filterFibers(fibers, 'Method', 'roi', 'ROI', 'roi.nii');
   ```
3. Legacy functions still work but will show deprecation warnings

## [1.0.0] - 2025-10-27

### Added - Initial Release

#### Core Functionality
- Extracted fiberfiltering module from LEAD-DBS
- Three core filtering functions:
  - ROI-based filtering (ea_filterfiber_roi.m)
  - Stimulation-based filtering (ea_filterfiber_stim.m)
  - Length-based filtering (ea_filterfiber_len.m)

#### Fiberfiltering Explorer
- Complete fiberfiltering_explorer module (49 files)
- Statistical analysis capabilities
- Cross-validation support
- Multiple connectivity calculation methods (VAT, PAM, fiber-based)
- 3D visualization tools

#### Statistical Tests
- 14 statistical test implementations
- T-tests (1-sample, 2-sample)
- Correlation tests (Spearman, Pearson, Bend)
- Weighted linear regression
- Proportion and rank-sum tests

#### Testing
- Comprehensive test suite with 18 test cases
- Tests for all three core filter functions
- Test runner script

#### Documentation
- FIBERFILTERING_README.md
- FIBERFILTERING_DEPENDENCIES.md
- CLEANUP_SUMMARY.md
- Detailed dependency analysis

### Removed from Original LEAD-DBS
- Electrode reconstruction (29 files)
- Normalization (21 files)
- Coregistration (26 files)
- VAT generation (14 files)
- Main GUI applications (10 files)
- Other explorers (navigator, sweetspot, networkmapping)
- Entire modules: clinical, genetics, cluster, dbshub, predict, programmer, etc.
- Total: 370 files removed, 81 directories removed, ~29M+ code size reduction

### Preserved
- All fiberfiltering functionality
- Essential helper functions (~100+ files)
- NIfTI I/O operations
- Coordinate conversion functions
- Spatial operations
- Configuration files

## [Unreleased]

### Planned for v2.0.0 Final
- Complete package documentation with examples for all functions
- CI/CD integration with automated testing
- Performance benchmarks
- Additional example scripts
- Video tutorials

### Future Enhancements
- Python interface (fiberfilt-py)
- Parallel processing optimization
- GPU acceleration for large connectomes
- Additional VAT models
- Web-based visualization
- Docker container for reproducibility

---

## Version Numbering

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version: Incompatible API changes
- **MINOR** version: Added functionality (backward compatible)
- **PATCH** version: Bug fixes (backward compatible)

## Links

- [Repository](https://github.com/your-repo/fiberfiltering)
- [Issues](https://github.com/your-repo/fiberfiltering/issues)
- [Documentation](docs/)
- [Original LEAD-DBS](https://www.lead-dbs.org)
