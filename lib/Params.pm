# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# The contents of this file are subject to the Mozilla Public
# License Version 1.1 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# The Original Code is the BugViewPlus Bugzilla Extension.
#
# The Initial Developer of the Original Code is Pami Ketolainen
# Portions created by the Initial Developer are Copyright (C) 2012 the
# Initial Developer. All Rights Reserved.
#
# Contributor(s):
#   Pami Ketolainen <pami.ketolainen@gmail.com>

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
