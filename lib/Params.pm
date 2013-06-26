# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (C) 2012 Jolla Ltd.
# Contact: Pami Ketolainen <pami.ketolainen@jollamobile.com>

package Bugzilla::Extension::BugViewPlus::Params;

use strict;
use warnings;

use Bugzilla::Config::Common;
use Bugzilla::Field;

sub get_param_list {
    my ($class) = @_;

    my @groups = sort @{Bugzilla->dbh->selectcol_arrayref(
            "SELECT name FROM groups")};
    my ($old_group) = grep {$_ eq 'bvp_edit_description'} @groups;
    unshift @groups, '';

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
            name => 'bvp_simple_bug_fields',
            desc => 'The bug fields shown in the simplified bug view. '.
                'Use a comma separated list of bug field names. "importance" '.
                'can be used to get the combined priority/severity/votes. '.
                '"#" can be used to split the fields in several columns',
            type => 't',
            default => 'bug_status,product,component,importance,#,'.
                'reporter,assigned_to'
        },
        {
            name => 'bvp_inline_editor',
            desc => 'Enable/disable the bug list inline editor.',
            type => 'b',
            default => 1
        },
    );
    return @param_list;
}

1;
