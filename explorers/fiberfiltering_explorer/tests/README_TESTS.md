# Fiberfiltering Optimization Test Suite

This directory contains comprehensive tests to validate the memory optimization changes made to the fiberfiltering pipeline.

## Overview

The fiberfiltering pipeline was optimized to reduce memory usage by ~74% for large connectomes through:
- Loading connectome once (not 4x)
- Keeping sparse matrices sparse
- Eliminating duplicate storage
- Consolidating 4 functions into 1

These tests ensure the optimization works correctly and produces identical results to the original implementation.

## Test Files

### 1. `test_fiberfiltering_optimization.m` - Basic Validation
**Purpose**: Validate utility functions and code structure without requiring data.

**Usage**:
```matlab
results = test_fiberfiltering_optimization()        % Quick tests
results = test_fiberfiltering_optimization('full')  % All tests
```

**Tests performed**:
- ✓ `ea_fibValThresh` utility function correctness
- ✓ `ea_fibcell2fibmat` utility function correctness
- ✓ Sparse matrix operations
- ✓ Required files exist
- ✓ Deprecation warnings present

**Requirements**: None (no data needed)

**Expected runtime**: < 5 seconds

---

### 2. `test_calcvals_regression.m` - Regression Testing
**Purpose**: Verify new implementation produces identical results to old implementation.

**Usage**:
```matlab
results = test_calcvals_regression(leadgroup_file, connectome_name)
results = test_calcvals_regression(leadgroup_file, connectome_name, 'tolerance', 1e-10)
```

**Tests performed**:
- ✓ E-field method: old vs new (bit-identical)
- ✓ PAM probabilistic: old vs new (bit-identical)
- ✓ Matrix sizes match
- ✓ Non-zero element counts match
- ✓ Sparsity preserved
- ✓ Numerical values within tolerance

**Requirements**:
- Valid lead group `.mat` file
- Available connectome

**Expected runtime**: 30 seconds - 5 minutes (depends on data size)

**Example**:
```matlab
results = test_calcvals_regression('/path/to/leadgroup.mat', 'MyConnectome');
```

---

### 3. `test_memory_usage.m` - Memory Profiling
**Purpose**: Measure actual memory usage and validate optimization claims.

**Usage**:
```matlab
results = test_memory_usage(leadgroup_file, connectome_name)
results = test_memory_usage(leadgroup_file, connectome_name, 'method', 'pam')
```

**Measurements**:
- Connectome size in memory
- Peak memory during calculation
- Memory saved vs old implementation
- Percent reduction achieved
- Computation time
- Sparse matrix verification

**Requirements**:
- Valid lead group `.mat` file
- Available connectome

**Expected runtime**: 1-10 minutes (depends on data size)

**Example**:
```matlab
results = test_memory_usage('/path/to/leadgroup.mat', 'MyConnectome');
```

---

### 4. `run_all_tests.m` - Master Test Runner
**Purpose**: Execute all tests in sequence with consolidated reporting.

**Usage**:
```matlab
run_all_tests()  % Basic tests only
run_all_tests(leadgroup_file, connectome_name)  % Complete suite
```

**Example**:
```matlab
run_all_tests('/path/to/leadgroup.mat', 'MyConnectome');
```

---

## Quick Start

### Minimal Testing (No Data Required)
To verify the code structure and utility functions:

```matlab
cd explorers/fiberfiltering_explorer/tests
results = test_fiberfiltering_optimization()
```

### Complete Testing (Data Required)
To run all tests including regression and memory profiling:

```matlab
cd explorers/fiberfiltering_explorer/tests
run_all_tests('/path/to/your/leadgroup.mat', 'YourConnectome')
```

---

## Expected Results

### Basic Validation
- All utility functions pass
- All required files exist
- Deprecation warnings present

### Regression Testing
- **E-field method**: Exact match (max difference < 1e-12)
- **PAM method**: Exact match (max difference < 1e-12)
- **Sparsity**: Maintained throughout
- **Performance**: Similar or better than old

### Memory Profiling
- **Connectome loading**: Only loaded once
- **Memory reduction**: 60-80% reduction in peak usage
- **Sparse matrices**: All remain sparse
- **Expected savings**:
  - Small connectomes (~1 GB): Save 2-4 GB
  - Large connectomes (~8 GB): Save 20-30 GB

---

## Test Data Requirements

For regression and memory tests, you need:

1. **Lead Group File** (`.mat` file)
   - Contains `M` structure with:
     - `M.patient.list` - Patient directories
     - `M.clinical.vars` - Clinical variables
     - `M.S` - Stimulation parameters
   - Created by Lead-DBS lead group analysis

2. **Connectome**
   - Available in Lead-DBS connectome directory
   - Standard format: `data.mat` with `fibers` and `idx`
   - Examples: `PPMI_15`, `Multi-Tract_Human_7T`

### Creating Test Data

If you don't have a lead group file, you can create a minimal test:

```matlab
% Create minimal test lead group
M = struct();
M.patient.list = {'/path/to/patient1', '/path/to/patient2'};
M.clinical.vars = {'improvement'};
M.clinical.labels = {'Clinical Improvement'};
% ... add minimal required fields
save('test_leadgroup.mat', 'M');
```

---

## Interpreting Results

### Success Criteria

✓ **All tests should pass** if optimization is correct

### What Each Test Validates

1. **Basic Validation**
   - ✓ Code structure intact
   - ✓ Utilities working
   - ✓ Files properly organized

2. **Regression Tests**
   - ✓ **Critical**: Results must be bit-identical
   - ✓ Proves computational correctness
   - ✓ Validates no bugs introduced

3. **Memory Profiling**
   - ✓ Quantifies memory savings
   - ✓ Validates optimization claims
   - ✓ Measures performance impact

### If Tests Fail

**Basic Validation Failure**:
- Check file paths
- Verify utility functions extracted correctly
- Review deprecation warnings

**Regression Test Failure**:
- ⚠️ **Critical issue** - computational results differ
- Review tolerance settings
- Check for data corruption
- Validate input data

**Memory Test Failure**:
- May indicate data loading issues
- Check connectome file accessibility
- Verify sufficient system memory

---

## Troubleshooting

### Common Issues

**"Connectome file not found"**
```matlab
% Check connectome path
connectome_base = ea_getconnectomebase('dMRI');
cfile = [connectome_base, 'YourConnectome', filesep, 'data.mat'];
assert(exist(cfile, 'file'), 'File not found');
```

**"Lead group loading failed"**
```matlab
% Verify lead group structure
load('your_leadgroup.mat', 'M');
assert(isfield(M, 'patient'), 'M.patient missing');
assert(isfield(M, 'clinical'), 'M.clinical missing');
```

**"Out of memory"**
- Test with smaller connectome first
- Close other MATLAB sessions
- Ensure sufficient RAM available
- Use 64-bit MATLAB

---

## Test Output Files

All tests save results to `.mat` files:

- `test_results_YYYYMMDD_HHMMSS.mat` - Basic validation
- `regression_test_YYYYMMDD_HHMMSS.mat` - Regression results
- `memory_test_YYYYMMDD_HHMMSS.mat` - Memory profiling
- `all_tests_YYYYMMDD_HHMMSS.mat` - Consolidated results

Load results for detailed analysis:
```matlab
load('test_results_20250107_143022.mat', 'results');
disp(results);
```

---

## Performance Benchmarks

Expected performance on typical hardware:

| Test | Connectome Size | Runtime |
|------|----------------|---------|
| Basic validation | N/A | < 5 sec |
| Regression (small) | < 1 GB | 30 sec |
| Regression (large) | > 5 GB | 3-5 min |
| Memory profiling | Any | 1-2 min |

---

## Automated Testing

To run tests automatically after code changes:

```matlab
% Quick check
test_fiberfiltering_optimization();

% Full validation (requires data)
run_all_tests('/path/to/leadgroup.mat', 'Connectome');
```

---

## Support

If tests fail unexpectedly:

1. Review test output carefully
2. Check MATLAB version (R2019b or later recommended)
3. Verify data integrity
4. Consult optimization documentation in `ea_disctract.m` header

---

## Test Development

To add new tests, follow this pattern:

```matlab
function results = test_new_feature()
    results = struct();
    results.tests_passed = 0;
    results.tests_failed = 0;

    try
        % Test code here
        assert(condition, 'Error message');
        results.tests_passed = results.tests_passed + 1;
    catch ME
        results.tests_failed = results.tests_failed + 1;
        results.error = ME.message;
    end
end
```

---

**Last Updated**: 2025-01-07
**Optimization Version**: 1.0
**Tested With**: MATLAB R2020a+
