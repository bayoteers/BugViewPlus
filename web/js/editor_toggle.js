// Toggle display mode between simple and advanced editors
var bvpToggleEditor = function(ev, ui)
{
    var button = $("#bvp_toggle_editor");
    $(".show-text,.hide-text", button).toggle();
    $("table.edit_form").toggleClass("bvp-simple");
    var minimal = button.data("minimal") ? false : true;
    button.data("minimal", minimal);
    if (ui != 'init') {
        $.cookie("bvp_hide_advanced", minimal || null);
    }
}

// Initialize simple editor toggle
var bvpInitEditorToggle = function(simpleSelector, hideAdvanced) {
    if (hideAdvanced == "remember") {
        hideAdvanced = $.cookie("bvp_hide_advanced") ? true : false;
    } else {
        hideAdvanced = hideAdvanced == "on" ? true : false;
    }
    var toggleButton = $("#bvp_toggle_editor").on('click', bvpToggleEditor);
    $("#bz_top_half_spacer").after(toggleButton);
    $(".bz_show_bug_column tr").not(
            $("table.edit_form").find(simpleSelector).closest("tr")
        ).addClass("bvp-advanced");
    if (hideAdvanced) {
        toggleButton.trigger('click', 'init');
    }
}
