# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (C) 2012-2017 Jolla Ltd.
# Contact: Pami Ketolainen <pami.ketolainen@jolla.com>

package Bugzilla::Extension::BugViewPlus::Params;

use strict;
use warnings;

use Bugzilla::Config::Common;
use Bugzilla::Field;
use Bugzilla::Constants qw(FIELD_TYPE_SINGLE_SELECT);

sub get_param_list {
    my ($class) = @_;

    my @groups = sort @{Bugzilla->dbh->selectcol_arrayref(
            "SELECT name FROM groups")};
    my ($old_group) = grep {$_ eq 'bvp_edit_description'} @groups;
    unshift @groups, '';
    my @select_fields = sort map (
        $_->name, @{Bugzilla->fields({type=>FIELD_TYPE_SINGLE_SELECT})}
    );

    my @param_list = (
        {
            name => 'bvp_description_edit_group',
            desc => 'User group that is allowed to edit bug descriptions',
            type    => 's',
            choices => \@groups,
            default => defined $old_group ? $old_group : '',
        },
        {
            name => 'bvp_description_editable_types',
            desc => 'Bug severities for which the description can be edited',
            type    => 'm',
            choices => get_legal_field_values('bug_severity'),
            default => []
        },
        {
            name => 'bvp_linkify_severity',
            desc => 'If true "<severity> #" will be linkified in bug comments',
            type    => 'b',
            default => 0,
        },

        {
            name => 'bvp_simple_bug_view',
            desc => 'Enable/disable the simplified bug view.',
            type => 'b',
            default => 1
        },
        {
            name => 'bvp_simple_fields_selector',
            desc => 'CSS selector for bug fields shown in the simple bug view. '.
                'Use a comma separated list of CSS selectors. The selectors '.
                'are used to get the list of tr-elements containing the '.
                'elements which will be shown in the simplified bug view.',
            type => 't',
            default => '#bz_field_status,#field_container_product,'.
                '#field_container_component,select#priority,'.
                '#bz_show_bug_column_2 th:first,#bz_assignee_input'
        },
        {
            name => 'bvp_inline_editor',
            desc => 'Enable/disable the bug list inline editor.',
            type => 'b',
            default => 1
        },
        {
            name => 'bvp_summary_prefix_fields',
            desc => 'Fields from which the value is added as prefix to summary',
            type    => 'm',
            choices => \@select_fields,
            default => [],
        },
    );
    return @param_list;
}

1;
