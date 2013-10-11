# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (C) 2012 Jolla Ltd.
# Contact: Pami Ketolainen <pami.ketolainen@jollamobile.com>

package Bugzilla::Extension::BugViewPlus;
use strict;
use base qw(Bugzilla::Extension);

use Bugzilla::Config qw(SetParam write_params);
use Bugzilla::Error;
use Bugzilla::Field qw(get_legal_field_values);
use Bugzilla::Template;
use Bugzilla::Util qw(detaint_natural trick_taint);

use Bugzilla::Extension::BugViewPlus::Template;

our $VERSION = '0.01';

sub install_update_db {
    my ($self, $args) = @_;

    my $old_group = Bugzilla->dbh->selectrow_hashref(
            "SELECT name, isactive, isbuggroup FROM groups ".
            "WHERE name = ?", undef, 'bvp_edit_description');
    if (defined $old_group &&
            !$old_group->{isbuggroup} && $old_group->{isactive}) {
        # Fix earlier installations group type
        Bugzilla->dbh->do(
            "UPDATE groups SET isbuggroup = 1, isactive = 0 WHERE id = ?",
            undef, $old_group->id);
    }
}

sub config_add_panels {
    my ($self, $args) = @_;
    my $modules = $args->{panel_modules};
    $modules->{BugViewPlus} = "Bugzilla::Extension::BugViewPlus::Params";
}

sub bb_group_params {
    my ($self, $args) = @_;
    push(@{$args->{group_params}}, 'bvp_description_edit_group');
}

sub bug_end_of_update {
    my ($self, $args) = @_;
    my $cgi = Bugzilla->cgi;
    my $dbh = Bugzilla->dbh;
    my ($bug, $timestamp) = @$args{qw(bug timestamp)};

    # Get the bug id passed to processbug.cgi
    my $bug_id = $cgi->param('id');
    return unless $bug_id;
    return unless detaint_natural($bug_id);

    # Make sure we are udating the same bug and not some related bug
    if ($bug->bug_id == $bug_id) {

        # Edit description related stuff
        my $group = Bugzilla->params->{'bvp_description_edit_group'};
        my $type_editable = grep {$_ eq $bug->bug_severity}
                @{Bugzilla->params->{bvp_description_editable_types}};
        if ($type_editable && Bugzilla->user->in_group($group)) {
            # Current description text
            my $old_desc = ${ @{ $bug->comments }[0] }{'thetext'};

            # Current descriptions comment id (in longdescs table)
            my $comment_id = ${ @{ $bug->comments }[0] }{'comment_id'};

            # The new description
            my $new_desc = $cgi->param('bvp_description');

            if ($new_desc) {
                trick_taint($new_desc);

                # Remove trailing whitespace
                $new_desc =~ s/\s*$//s;
                $new_desc =~ s/\r\n?/\n/g;    # Get rid of \r.

                if ($old_desc ne $new_desc) {
                    # Add or update the timestamp in description
                    my $stamp = "> Edited by ".Bugzilla->user->name." on ".$timestamp;
                    if (! ($new_desc =~ s/> Edited by .* on .*$/$stamp/)) {
                        $new_desc .= "\n\n".$stamp;
                    }
                    # Push to database
                    $dbh->do('UPDATE longdescs SET thetext = ? '.
                              'WHERE bug_id = ? AND comment_id = ?',
                            undef, $new_desc, $bug->bug_id, $comment_id);
                }
            }
        }
    }
}

sub bug_format_comment {
    my ($self, $args) = @_;
    return unless Bugzilla->params->{bvp_linkify_severity};

    my $regexes = $args->{regexes};
    # Turn '<severity> #' into bug link in comments
    if (!defined $self->{bug_severities}) {
        $self->{bug_severities} = get_legal_field_values('bug_severity');
    }
    foreach my $value (@{$self->{bug_severities}}) {
        push (@$regexes, { match => qr/($value)\s*(\d+)/i,
                replace => \&_replace_bug_link } );
    }
}

sub db_schema_abstract_schema {
    my ($self, $args) = @_;
    my $schema = $args->{schema};

    # Table for storing the bug templates
    $schema->{bvp_templates} = {
        FIELDS => [
            id => {TYPE => 'MEDIUMSERIAL', NOTNULL => 1, PRIMARYKEY => 1},
            name => {TYPE => 'TINYTEXT', NOTNULL => 1},
            is_active => {TYPE => 'BOOLEAN', NOTNULL => 1, DEFAULT => 0},
            description => {TYPE => 'TINYTEXT'},
            content => {TYPE => 'MEDIUMTEXT'},
        ],
        INDEXES => [],
    };
}

sub object_end_of_update {
    my ($self, $args) = @_;
    my ($new_obj, $old_obj, $changes) = @$args{qw(object old_object changes)};

    # Update user group param if group name changes
    if ($new_obj->isa("Bugzilla::Group") && defined $changes->{name}) {
        if ($old_obj->name eq Bugzilla->params->{bvp_description_edit_group}) {
            SetParam('bvp_description_edit_group', $new_obj->name);
            write_params();
        }
    }
}

sub page_before_template {
    my ($self, $args) = @_;
    return unless ($args->{page_id} eq 'bvp_template.html');
    ThrowUserError('auth_failure', {
            group => 'admin', action => 'access',
            object => 'administrative_pages'
        }) unless Bugzilla->user->in_group('admin');;
    my $vars = $args->{vars};
    my $cgi = Bugzilla->cgi;
    my $tid = $cgi->param('tid');
    my $action = $cgi->param('action') || '';
    my $current;
    if (defined $tid) {
        $current = Bugzilla::Extension::BugViewPlus::Template->check({id=>$tid});
    }
    if ($action) {
        my $values = {
            name => scalar $cgi->param('name'),
            is_active => scalar $cgi->param('is_active'),
            description => scalar $cgi->param('description'),
            content => scalar $cgi->param('content'),
        };
        if ($action eq 'create') {
            $current = Bugzilla::Extension::BugViewPlus::Template->create($values);
            $vars->{message} = 'bvp_template_created';
        } elsif ($action eq 'save') {
            ThrowCodeError('param_required', {param => 'tid', function=>'save'})
                unless defined $current;
            $current->set_all($values);
            $current->update();
            $vars->{message} = 'bvp_template_saved';
        } elsif ($action eq 'remove') {
            ThrowCodeError('param_required', {param => 'tid', function=>'remove'})
                unless defined $current;
            $current->remove_from_db();
            $vars->{message} = 'bvp_template_removed';
            $vars->{name} = $current->name;
            $current = undef;
        } else {
            ThrowCodeError('param_invalid',
                {param => $action, function=>'action'});
        }
    }
    $vars->{current} = $current;
    $vars->{templates} = [Bugzilla::Extension::BugViewPlus::Template->get_all()];
}

sub template_before_process {
    my ($self, $args) = @_;
    return unless $args->{file} eq 'bug/comments.html.tmpl';

    my $group = Bugzilla->params->{'bvp_description_edit_group'};
    my $severity = $args->{vars}->{bug}->bug_severity;
    my $type_editable = grep {$_ eq $severity}
            @{Bugzilla->params->{bvp_description_editable_types}};
    $args->{vars}->{can_edit_description} =
        $type_editable && Bugzilla->user->in_group($group) ? 1 : 0;
}

sub _replace_bug_link {
    my $args = shift;
    my $type = $args->{matches}->[0];
    my $id = $args->{matches}->[1];

    return Bugzilla::Template::get_bug_link($id, $type." ".$id);
}

__PACKAGE__->NAME;
