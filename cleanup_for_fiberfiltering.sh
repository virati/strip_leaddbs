#!/bin/bash
# Cleanup script to strip LEAD-DBS down to fiberfiltering essentials
# This removes all files not needed for fiberfiltering functionality

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "════════════════════════════════════════════════════════════"
echo "  LEAD-DBS Fiberfiltering-Only Cleanup Script"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "This will remove ALL files not needed for fiberfiltering."
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5

echo ""
echo "Starting cleanup..."
echo ""

# Create backup list of what we're removing
mkdir -p cleanup_analysis/removed
date > cleanup_analysis/removed/cleanup_timestamp.txt

# Function to safely remove and log
safe_remove() {
    local path="$1"
    if [ -e "$path" ]; then
        echo "$path" >> cleanup_analysis/removed/removed_files.txt
        rm -rf "$path"
        echo "  ✓ Removed: $path"
    fi
}

# 1. Remove entire unnecessary directories
echo "Removing unnecessary directories..."
safe_remove "clinical"
safe_remove "genetics"
safe_remove "cluster"
safe_remove "dbshub"
safe_remove "predict"
safe_remove "programmer"
safe_remove "programmergroup"
safe_remove "dependency"
safe_remove "dev"
safe_remove "vatmodel"
safe_remove "ls"
safe_remove "icons"

# 2. Remove other explorers (keep only fiberfiltering_explorer and stattests)
echo ""
echo "Removing other explorer modules..."
if [ -d "explorers" ]; then
    for explorer in explorers/*/; do
        explorer_name=$(basename "$explorer")
        if [ "$explorer_name" != "fiberfiltering_explorer" ] && [ "$explorer_name" != "stattests" ]; then
            safe_remove "$explorer"
        fi
    done
fi

# 3. Remove support scripts (keep only minimal needed ones)
echo ""
echo "Cleaning support_scripts..."
if [ -d "support_scripts" ]; then
    # Keep explorer_tools_scripting, remove others
    for item in support_scripts/*; do
        item_name=$(basename "$item")
        if [ "$item_name" != "explorer_tools_scripting" ]; then
            safe_remove "$item"
        fi
    done
fi

# 4. Remove main GUI files
echo ""
echo "Removing main GUI applications..."
safe_remove "lead.m"
safe_remove "lead.fig"
safe_remove "lead_dbs.mlapp"
safe_remove "lead_group.m"
safe_remove "lead_group.fig"
safe_remove "lead_group_connectome.m"
safe_remove "lead_group_connectome.fig"
safe_remove "lead_predict.m"
safe_remove "lead_predict.fig"
safe_remove "lead_anatomy.m"
safe_remove "lead_anatomy.fig"
safe_remove "lead_demo.m"
safe_remove "nifti_to_bids.mlapp"
safe_remove "plot_studio.mlapp"
safe_remove "ea_stimparams.mlapp"

# 5. Remove electrode reconstruction files
echo ""
echo "Removing electrode reconstruction files..."
for file in cleanup_analysis/removable_reconstruction.txt; do
    if [ -f "$file" ]; then
        while IFS= read -r filepath; do
            safe_remove "$filepath"
        done < "$file"
    fi
done

# 6. Remove normalization files
echo ""
echo "Removing normalization files..."
for file in cleanup_analysis/removable_normalization.txt; do
    if [ -f "$file" ]; then
        while IFS= read -r filepath; do
            safe_remove "$filepath"
        done < "$file"
    fi
done

# 7. Remove coregistration files
echo ""
echo "Removing coregistration files..."
for file in cleanup_analysis/removable_coregistration.txt; do
    if [ -f "$file" ]; then
        while IFS= read -r filepath; do
            safe_remove "$filepath"
        done < "$file"
    fi
done

# 8. Remove VAT generation files
echo ""
echo "Removing VAT generation files..."
for file in cleanup_analysis/removable_vat.txt; do
    if [ -f "$file" ]; then
        while IFS= read -r filepath; do
            safe_remove "$filepath"
        done < "$file"
    fi
done

# 9. Remove atlas/visualization GUI files
echo ""
echo "Removing atlas/visualization GUIs..."
safe_remove "ea_atlasselect.m"
safe_remove "ea_atlasselect.fig"
safe_remove "ea_cortexselect.m"
safe_remove "ea_cortexselect.fig"
safe_remove "ea_anatomycontrol.m"
safe_remove "ea_anatomycontrol.fig"
safe_remove "ea_checkstructures.m"
safe_remove "ea_checkstructures.fig"
safe_remove "ea_checkreg.fig"
safe_remove "ea_imageclassifier.m"
safe_remove "ea_imageclassifier.fig"
safe_remove "ea_methodsdisp.m"
safe_remove "ea_methodsdisp.fig"
safe_remove "ea_textdisp.m"
safe_remove "ea_textdisp.fig"
safe_remove "ea_spec2dwrite.m"
safe_remove "ea_spec2dwrite.fig"
safe_remove "ea_subcorticalrefine.m"
safe_remove "ea_subcorticalrefine.fig"
safe_remove "ea_edit_regressor.m"
safe_remove "ea_edit_regressor.fig"
safe_remove "ea_lg_3dsetting.m"
safe_remove "ea_lg_3dsetting.fig"
safe_remove "ea_lg_stats.m"
safe_remove "ea_lg_stats.fig"

# 10. Remove image import/conversion tools
echo ""
echo "Removing import/conversion tools..."
safe_remove "ea_spm_dicom_import.m"
safe_remove "ea_nifti_to_bids.m"
safe_remove "ea_importfs.m"
safe_remove "ea_importcorticalels.m"
safe_remove "ea_read_bids.m"

# 11. Remove visualization tools not needed
echo ""
echo "Removing unnecessary visualization tools..."
safe_remove "ea_imshow3d.m"
safe_remove "ea_imshowpair.m"
safe_remove "ea_elvis.m"
safe_remove "ea_addobj.m"
safe_remove "ea_showatlas.m"
safe_remove "ea_showcortex.m"
safe_remove "ea_showcorticalstrip.m"
safe_remove "ea_showelectrode.m"
safe_remove "ea_showisovolume.m"
safe_remove "ea_show_light.m"
safe_remove "ea_show_normalization.m"
safe_remove "ea_show_coregistration.m"
safe_remove "ea_showdis.m"

# 12. Remove electrode/trajectory files
echo ""
echo "Removing electrode and trajectory files..."
safe_remove "ea_autocoord.m"
safe_remove "ea_diode_*.m"
safe_remove "ea_manualreconstruction.m"
safe_remove "ea_reconstruct_coords.m"
safe_remove "ea_reconstruct.m"
safe_remove "ea_reconstruct_trajectory.m"
safe_remove "ea_reconstruction2acpc.m"
safe_remove "ea_reconstruction2mni.m"
safe_remove "ea_reconstruction2native.m"
safe_remove "ea_refinecoords.m"
safe_remove "ea_correctcoords.m"
safe_remove "ea_segment_electrode.m"
safe_remove "ea_load_electrode.m"
safe_remove "ea_save_electrode.m"
safe_remove "ea_load_reconstruction.m"
safe_remove "ea_save_reconstruction.m"
safe_remove "ea_renderelstruct.m"
safe_remove "ea_mapelmodel2reco.m"

# 13. Remove run/control files not needed
echo ""
echo "Removing run/control files..."
safe_remove "ea_run.m"
safe_remove "ea_runmanual.m"
safe_remove "ea_runmanualslicer.m"
safe_remove "ea_runslicer.m"
safe_remove "ea_runpacer.m"
safe_remove "ea_runtraccore.m"
safe_remove "ea_runwarpdrive.m"
safe_remove "ea_run_cluster.m"
safe_remove "ea_run_cleartune_from_leadDBS.m"
safe_remove "ea_command_line_run.m"

# 14. Remove processing files
echo ""
echo "Removing processing files..."
safe_remove "ea_anatpreprocess.m"
safe_remove "ea_apply_coregistration.m"
safe_remove "ea_apply_normalization.m"
safe_remove "ea_apply_normalization_tofile.m"
safe_remove "ea_precoreg.m"
safe_remove "ea_resliceanat.m"

# 15. Remove helper/toolbox directories we don't need
echo ""
echo "Cleaning toolbox directory..."
if [ -d "toolbox" ]; then
    # Keep only essential toolboxes
    for item in toolbox/*; do
        item_name=$(basename "$item")
        # Keep SPM-related if needed, remove most others
        if [ "$item_name" != "spm12" ]; then  # Adjust based on actual needs
            safe_remove "$item"
        fi
    done
fi

# 16. Remove non-essential classes
echo ""
echo "Cleaning classes directory..."
if [ -d "classes" ]; then
    # May need to analyze which classes are actually used
    # For now, be conservative
    echo "  ⚠ Skipping classes/ - needs manual review"
fi

# 17. Remove helper directories/files not needed
echo ""
echo "Cleaning helpers directory..."
# Keep the helpers we identified as needed, remove others
# This is selective - removing known unnecessary ones
safe_remove "helpers/ea_legacy2bids.m"
safe_remove "helpers/ea_recover_native_to_mni.py"
safe_remove "helpers/ea_slicer_invert_transform.py"
safe_remove "helpers/ea_gdcm_slicer_dicom_import.py"
safe_remove "helpers/ea_leador_create_or_scene.py"
safe_remove "helpers/demo_patient"

# Count remaining files
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Cleanup Complete!"
echo "════════════════════════════════════════════════════════════"
echo ""

# Statistics
total_removed=$(wc -l < cleanup_analysis/removed/removed_files.txt 2>/dev/null || echo "0")
remaining_m_files=$(find . -name "*.m" -type f | grep -v "\.git" | wc -l)
remaining_mlapp_files=$(find . -name "*.mlapp" -type f | grep -v "\.git" | wc -l)

echo "Statistics:"
echo "  Files/directories removed: $total_removed"
echo "  Remaining .m files: $remaining_m_files"
echo "  Remaining .mlapp files: $remaining_mlapp_files"
echo ""
echo "Preserved for fiberfiltering:"
echo "  ✓ explorers/fiberfiltering_explorer/"
echo "  ✓ explorers/stattests/"
echo "  ✓ helpers/ea_filterfiber_*.m"
echo "  ✓ Essential helper functions"
echo "  ✓ Tests"
echo "  ✓ Documentation"
echo ""
echo "Removed files logged to: cleanup_analysis/removed/removed_files.txt"
echo ""
echo "Next steps:"
echo "  1. Review remaining files"
echo "  2. Test fiberfiltering functionality (requires MATLAB)"
echo "  3. Commit changes if satisfied"
echo ""
