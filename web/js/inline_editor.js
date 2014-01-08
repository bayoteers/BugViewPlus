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
    bug_status: 'status'
};


var inlineEditCancel = function(ev)
{
    var link = $(ev.currentTarget);
    _closeInlineEdit(link);
    ev.preventDefault();
};

var _closeInlineEdit = function(link)
{
    link.attr('title', 'Edit')
        .text('[+]')
        .off('click').on('click', inlineEditOpen);
    var row = link.parents('tr').eq(0);
    row.next('tr.editor_row').remove();
    row.next('tr.comment_row').remove();
};


var inlineEditOpen = function(ev)
{
    var link = $(ev.currentTarget);
    var row = link.parents('tr').eq(0);
    var bug = link.data('bug');
    if (bug == undefined) {
        var bugId = row.attr('id').slice(1);
        Bug.get(bugId, function(bug) {
            link.data('bug', bug);
            bug.updated(_inlineEditUpdate);
            _openInlineEdit(bug, link, row);});
    } else {
        _openInlineEdit(bug, link, row);
    }
    ev.preventDefault();
};

var _openInlineEdit = function(bug, link, row)
{
    link.attr('title', 'Cancel')
        .text('[-]')
        .off('click')
        .on('click', inlineEditCancel);

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
            try {
                var field = bug.field(fname);
            } catch (e) {
                return;
            }
            if (field.immutable) return;
            orig_cell.data('name', name);
            var input = bug.createInput(field, false, true);
            if (['remaining_time', 'estimated_time', 'work_time'].indexOf(field.name) > -1){
                input.css('width', '4em');
            } else {
                input.css('width', '100%');
            }
            if (field.name == 'work_time') cell.append("+");
            cell.append(input);
        } else if (orig_cell.hasClass('button_column')) {
            $('<button class="inline_edit" type="button">Save</button>')
                .button({
                    text: false,
                    icons: {primary: 'ui-icon-disk'}
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
    var link = row.find('a.inline_edit');
    var bug = link.data('bug');
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
        _closeInlineEdit(link);
    });
    ev.preventDefault();
};

var _inlineEditUpdate = function(bug, name, value)
{
    var row = $('table.bz_buglist tr#b'+bug.value('id'));
    row.find('td').not('.button_column').each(function() {
        var element = $(this);
        if(element.data('name') != name) return;
        name = name == 'work_time' ? 'actual_time' : name;
        try {
            var field = bug.field(name);
        } catch(e) {
            return
        }
        if (field.multivalue)
            value = value.join(', ');
        if(value != undefined) element.find('span,a').pushStack(element).first().text(value);
    });
};

var initInlineEditor = function() {
    var rows = $('table.bz_buglist tr.bz_bugitem');
    rows.append('<td class="button_column"><a href="#" title="Edit" class="inline_edit">[+]</a></td>');
    $('table.bz_buglist a.inline_edit').click(inlineEditOpen);
    $('tr.bz_time_summary_line').append('<td class="bz_total">');
};

$(initInlineEditor);
