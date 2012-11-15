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

    my @legal_severities = @{get_legal_field_values('bug_severity')};

    my @param_list = (
        {
            name => 'bvp_description_editable_types',
            desc => 'Bug severities for which the description can be edited',
            type    => 'm',
            choices => \@legal_severities,
            default => [ $legal_severities[-1] ]
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
    );
    return @param_list;
}

1;
