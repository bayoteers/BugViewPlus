#!/usr/bin/perl -w
#
# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (C) 2017 Jolla Ltd.
# Contact: Pami Ketolainen <pami.ketolainen@jolla.com>
#
# Script to update all bug summary prefixes after updating the summary
# prefix fields. If fields were removed, add the removed field names as
# arguments to the script.

use strict;
use warnings;
use lib qw(. lib);

use Bugzilla;
BEGIN { Bugzilla->extensions }

use Bugzilla::Extension::BugViewPlus::Util qw(prefix_shortdesc);

my $bug_ids = Bugzilla->dbh->selectcol_arrayref("SELECT bug_id FROM bugs");

my @to_remove = @ARGV;

foreach my $bug_id (@$bug_ids) {
    my $bug = Bugzilla::Bug->new($bug_id);
    my $old = $bug->short_desc;
    prefix_shortdesc($bug, undef, \@to_remove);
    my $new = $bug->short_desc;
    if ($old ne $new) {
        print "$bug_id $old -> $new\n";
    }
}
