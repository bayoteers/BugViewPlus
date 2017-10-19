# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (C) 2017 Jolla Ltd.
# Contact: Pami Ketolainen <pami.ketolainen@jolla.com>

package Bugzilla::Extension::BugViewPlus::Util;

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT = qw(
    add_prefix_tag
    prefix_shortdesc
);

sub add_prefix_tag {
    my $params = shift || {};
    my $text = $params->{text};
    my $newtag = $params->{tag} ? "[".uc($params->{tag})."]" : "";
    my @replace = map {"[".uc($_)."]"} @{$params->{replace} || []};
    push(@replace, $newtag) if $newtag;

    # Get old tags from the text
    my @oldtags;
    while ($text =~ /^(\[[^]]+\])?\s*(.*)/) {
        last if (!defined $1);
        push(@oldtags, uc($1));
        $text = $2;
    }

    # Replace any old tags to be replaced
    my @newtags;
    # If newtag isempty, we preted it was added and just remove any old tags
    # in replace
    my $added = $newtag ? 0 : 1;
    for my $oldtag (@oldtags) {
        if (grep {$oldtag eq $_} @replace) {
            push(@newtags, $newtag) unless $added;
            $added = 1;
            next;
        }
        push(@newtags, $oldtag);
    }
    # Add the new tag if it didn't replace some existing tag
    push(@newtags, $newtag) unless $added;
    return join('', @newtags)." $text";
}

sub prefix_shortdesc {
    my ($bug, $changes, $to_remove) = @_;
    my $prefix_fields = Bugzilla->params->{bvp_summary_prefix_fields};
    $to_remove = defined $to_remove ? $to_remove : [];
    return unless (@$prefix_fields or @$to_remove);

    my $summary = $bug->short_desc;
    for my $fname (sort @$prefix_fields) {
        my @values = grep {$_ ne '---'} map {$_->name} @{
            Bugzilla->fields({by_name => 1})->{$fname}->legal_values
        };
        my $prefix = uc($bug->$fname);
        $summary = add_prefix_tag({
            text => $summary,
            tag => $prefix,
            replace => \@values,
        });
    }
    for my $fname (sort @$to_remove) {
        my @values = grep {$_ ne '---'} map {$_->name} @{
            Bugzilla->fields({by_name => 1})->{$fname}->legal_values
        };
        $summary = add_prefix_tag({
            text => $summary,
            tag => '',
            replace => \@values,
        });
    }

    if ($bug->short_desc ne $summary) {
        if (defined $changes) {
            my $old_summary = defined $changes->{short_desc} ?
                $changes->{short_desc}->[0] : $bug->short_desc;
            if ($old_summary ne $summary) {
                $changes->{short_desc} = [$old_summary, $summary];
            } else {
                delete $changes->{short_desc};
            }
        }
        $bug->{short_desc} = $summary;
        Bugzilla->dbh->do('UPDATE bugs SET short_desc = ? WHERE bug_id = ?',
            undef, $summary, $bug->id);
    }
}

1;
