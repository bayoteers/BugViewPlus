/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2012 Jolla Ltd.
 * Contact: Pami Ketolainen <pami.ketolainen@jollamobile.com>
 */

var INLINE_EDIT_COL_MAP = {
    short_short_desc: 'summary',
    assigned_to_realname: 'assigned_to',
    bug_status: 'status',
};


var inlineEditCancel = function(ev)
{
    var button = $(ev.currentTarget);
    _closeInlineEdit(button);
};

var _closeInlineEdit = function(button)
{
    button.button({
        label: 'Edit',
        text: false,
        icons: {primary: 'ui-icon-pencil'},
    }).off('click').on('click', inlineEditOpen);
    var row = button.parents('tr').eq(0);
    row.next('tr.editor_row').remove();
    row.next('tr.comment_row').remove();
};


var inlineEditOpen = function(ev)
{
    var button = $(ev.currentTarget);
    var row = button.parents('tr').eq(0);
    var bug = button.data('bug');
    if (bug == undefined) {
        var bugId = row.attr('id').slice(1);
        Bug.get(bugId, function(bug) {
            button.data('bug', bug);
            bug.updated(_inlineEditUpdate);
            _openInlineEdit(bug, button, row);});
    } else {
        _openInlineEdit(bug, button, row);
    }
};

var _openInlineEdit = function(bug, button, row)
{
    button.button({
        text: false,
        label: 'Cancel',
        icons: {primary: 'ui-icon ui-icon-arrowreturnthick-1-w'},
    }).off('click').on('click', inlineEditCancel);

    var colCount = row.find('td').size();
    var editRow = $('<tr class="editor_row"></tr>');
    row.find('td').each(function() {
        var orig_cell = $(this);
        var name;
        $.each(INLINE_EDIT_COLUMNS, function(i, col) {
            if (orig_cell.hasClass('bz_' + col + '_column')) {
                name = INLINE_EDIT_COL_MAP[col] || col;
                return false;
            }
        });
        var cell = $('<td></td>');
        cell.addClass(orig_cell[0].className);
        editRow.append(cell);
        if (name) {
            var fname = name == 'actual_time' ? 'work_time' : name
            var fd = Bug.fd(fname);
            if (fd == undefined || fd.immutable) return;
            orig_cell.data('name', name);
            var input = bug.createInput(fd, false, true);
            if (['remaining_time', 'estimated_time', 'work_time'].indexOf(fd.name) > -1){
                input.css('width', '4em');
            } else {
                input.css('width', '100%');
            }
            if (fd.name == 'work_time') cell.append("+");
            cell.append(input);
        } else if (orig_cell.hasClass('button_column')) {
            $('<buton class="inline_edit" type="button">Save</button>')
                .button({
                    text: false,
                    icons: {primary: 'ui-icon-disk'},
                    })
                .appendTo(cell)
                .on('click', _inlineEditSave);
        }
    });

    row.after(editRow);

    commentRow = $('<tr class="comment_row"><th>Comment:</th></tr>');
    var cell = $('<td>').attr('colspan', colCount - 1);
    var comment = $('<textarea name="comment" rows="1" cols="80"></textarea>')
        .focus(function(ev) { $(ev.currentTarget).attr('rows', 5)})
        .blur(function(ev) { $(ev.currentTarget).attr('rows', 1)})

    cell.append(comment);
    commentRow.append(cell);
    editRow.after(commentRow);
};

var _inlineEditSave = function(ev)
{
    var row = $(ev.currentTarget).parents('tr').eq(0).prev("tr.bz_bugitem");
    var button = row.find('button');
    var bug = button.data('bug');
    var editRows = row.nextUntil('tr.bz_bugitem');
    editRows.find('td > *').filter(':input').each(function() {
        // Make sure all values are set
        var input = $(this);
        var name = input.attr('name');
        if (!name) return;
        bug.set(name, input.val());
    });
    bug.save().done(function() {
        // Update bug row when save is done
        _closeInlineEdit(button);
    });
};

var _inlineEditUpdate = function(bug, name, value)
{
    var row = $('table.bz_buglist tr#b'+bug.value('id'));
    row.find('td').not('.button_column').each(function() {
        var element = $(this);
        if(element.data('name') != name) return;
        name = name == 'work_time' ? 'actual_time' : name;
        if (Bug.fd(name).multivalue)
            value = value.join(', ');
        if(value != undefined) element.find('span,a').pushStack(element).first().text(value);
    });
};

var initInlineEditor = function() {
    var rows = $('table.bz_buglist tr.bz_bugitem');
    rows.append('<td class="button_column"><button type="button" class="inline_edit"></button></td>');
    $('table.bz_buglist button.inline_edit').button({
        label: 'Edit',
        text: false,
        icons: {primary: 'ui-icon-pencil'},
    }).click(inlineEditOpen);
    $('tr.bz_time_summary_line').append('<td class="bz_total">');
};
