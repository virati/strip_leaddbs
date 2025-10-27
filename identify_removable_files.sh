#!/bin/bash
# Script to identify files that can be removed for fiberfiltering-only installation
# Creates lists of files to keep vs remove

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Analyzing LEAD-DBS directory for fiberfiltering-only installation..."
echo ""

# Create output directory
mkdir -p cleanup_analysis

# Files to KEEP - Essential for fiberfiltering
cat > cleanup_analysis/files_to_keep.txt << 'EOF'
# Core fiberfiltering filter functions
helpers/ea_filterfiber_roi.m
helpers/ea_filterfiber_stim.m
helpers/ea_filterfiber_len.m

# Fiberfiltering explorer directory (all files)
explorers/fiberfiltering_explorer/

# Statistical tests
explorers/stattests/

# Essential helpers - NIfTI I/O
helpers/ea_load_nii.m
helpers/ea_write_nii.m
helpers/ea_niifileparts.m
helpers/ea_niigz.m
helpers/ea_detvoxsize.m

# Essential helpers - Coordinate conversion
helpers/ea_vox2mm.m
helpers/ea_mm2vox.m
helpers/ea_mm2uniqueVoxInd.m
helpers/ea_get_affine.m

# Essential helpers - Spatial
helpers/ea_spherical_roi.m
helpers/ea_autocrop.m

# Essential helpers - Path/space
helpers/space/
helpers/ea_getconnectomebase.m

# Essential helpers - Statistics
helpers/stats/ea_resid.m
helpers/ea_color_wes.m
helpers/ea_SigmoidFromEfield.m

# Essential helpers - GUI/File ops
helpers/gui/ea_mkdir.m
helpers/ea_error.m
helpers/ea_warndlg.m

# Configuration
common/ea_prefs_default.m
common/ea_prefs_default.json
common/ea_prefs_default.mat

# Core system files
ea_space.m
ea_getearoot.m
ea_prefs.m
ea_defaultoptions.m
ea_nanmean.m

# Tests
tests/

# Documentation
README.md
LICENSE.md
FIBERFILTERING_DEPENDENCIES.md

# Git files
.git/
.gitignore
.gitattributes
EOF

# Create list of removable categories
cat > cleanup_analysis/removable_categories.txt << 'EOF'
# Categories of files that can be removed for fiberfiltering-only:

1. Electrode Reconstruction
   - ea_autocoord.m
   - ea_diode_*.m
   - ea_manualreconstruction.m
   - ea_reconstruct*.m
   - ea_segment_electrode.m

2. Normalization
   - ea_normalize*.m
   - ea_normsettings*.m
   - ea_normsettings*.fig

3. Coregistration
   - ea_coreg*.m
   - ea_spm_coreg.m
   - ea_show_coregistration.m
   - ea_checkreg.m
   - ea_checkreg.fig

4. VAT Generation
   - ea_genvat_*.m
   - ea_vatsettings_*.m
   - ea_vatsettings_*.fig
   - ea_vatsettings_*.mlapp
   - vatmodel/

5. Main GUI Applications (not fiberfiltering)
   - lead.m
   - lead.fig
   - lead_dbs.mlapp
   - lead_group.m
   - lead_group.fig
   - lead_group_connectome.m
   - lead_group_connectome.fig
   - lead_predict.m
   - lead_predict.fig
   - lead_anatomy.m
   - lead_anatomy.fig
   - lead_demo.m
   - nifti_to_bids.mlapp
   - plot_studio.mlapp
   - ea_stimparams.mlapp

6. Other Explorers (not fiberfiltering)
   - explorers/navigator/
   - explorers/sweetspot_explorer/
   - explorers/networkmapping_explorer/

7. Non-essential modules
   - clinical/
   - genetics/
   - cluster/
   - dbshub/
   - predict/
   - programmer/
   - programmergroup/

8. Atlas/Visualization (mostly removable)
   - ea_atlasselect.m
   - ea_atlasselect.fig
   - ea_cortexselect.m
   - ea_cortexselect.fig
   - ea_showatlas.m
   - ea_showcortex.m
   - ea_anatomycontrol.m
   - ea_anatomycontrol.fig

9. Helper scripts
   - support_scripts/ (except explorer_tools_scripting)
   - dev/
   - tools/ (most can be removed)

10. Import/Export (mostly removable)
    - ea_importfs.m
    - ea_importcorticalels.m
    - ea_spm_dicom_import.m
    - ea_nifti_to_bids.m

11. Image processing (mostly removable)
    - ea_imshow3d.m
    - ea_imshowpair.m
    - ea_imageclassifier.m
    - ea_imageclassifier.fig

12. Dependency/External (check if really needed)
    - dependency/
    - toolbox/ (may need some)
    - external_libraries_ls

13. Classes (check which are needed)
    - classes/ (most may not be needed for basic fiberfiltering)
EOF

# Now find actual files in each category
echo "Scanning for removable files..."

# Create comprehensive file list
find . -type f \( -name "*.m" -o -name "*.fig" -o -name "*.mlapp" \) | \
    grep -v "\.git" | \
    grep -v "explorers/fiberfiltering_explorer" | \
    grep -v "explorers/stattests" | \
    grep -v "tests/" | \
    sort > cleanup_analysis/all_matlab_files.txt

# Find electrode reconstruction files
echo "Finding electrode reconstruction files..."
grep -E "(autocoord|diode_|manualreconstruction|reconstruct|segment_electrode)" \
    cleanup_analysis/all_matlab_files.txt > cleanup_analysis/removable_reconstruction.txt || true

# Find normalization files
echo "Finding normalization files..."
grep -E "(normalize|normsettings)" \
    cleanup_analysis/all_matlab_files.txt > cleanup_analysis/removable_normalization.txt || true

# Find coregistration files
echo "Finding coregistration files..."
grep -E "(coreg|checkreg)" \
    cleanup_analysis/all_matlab_files.txt > cleanup_analysis/removable_coregistration.txt || true

# Find VAT files
echo "Finding VAT generation files..."
grep -E "(genvat|vatsettings)" \
    cleanup_analysis/all_matlab_files.txt > cleanup_analysis/removable_vat.txt || true

# Find main GUI files
echo "Finding main GUI files..."
grep -E "(^./lead\.m|^./lead\.fig|lead_dbs\.mlapp|lead_group\.|lead_predict\.|lead_anatomy\.|lead_demo\.m)" \
    cleanup_analysis/all_matlab_files.txt > cleanup_analysis/removable_main_guis.txt || true

# Count files
echo ""
echo "Analysis complete! Results in cleanup_analysis/"
echo ""
echo "Summary:"
total_files=$(wc -l < cleanup_analysis/all_matlab_files.txt)
reconstruction_files=$(wc -l < cleanup_analysis/removable_reconstruction.txt)
normalization_files=$(wc -l < cleanup_analysis/removable_normalization.txt)
coregistration_files=$(wc -l < cleanup_analysis/removable_coregistration.txt)
vat_files=$(wc -l < cleanup_analysis/removable_vat.txt)
gui_files=$(wc -l < cleanup_analysis/removable_main_guis.txt)

echo "  Total MATLAB files: $total_files"
echo "  Electrode reconstruction files: $reconstruction_files"
echo "  Normalization files: $normalization_files"
echo "  Coregistration files: $coregistration_files"
echo "  VAT generation files: $vat_files"
echo "  Main GUI files: $gui_files"
echo ""

# Directories to potentially remove entirely
echo "Large directories that can likely be removed:"
du -sh clinical genetics cluster dbshub predict programmer programmergroup dependency dev 2>/dev/null || true
echo ""

echo "Review the files in cleanup_analysis/ before deletion!"
echo ""
echo "To see detailed file lists:"
echo "  cat cleanup_analysis/removable_*.txt"
