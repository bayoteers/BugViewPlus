# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (C) 2013-2017 Jolla Ltd.
# Contact: Pami Ketolainen <pami.ketolainen@jolla.com>


=head1 NAME

Bugzilla::Extension::BugViewPlus::Template

=head1 SYNOPSIS

    use Bugzilla::Extension::BugViewPlus::Template;

    my $template = Bugzilla::Extension::BugViewPlus::Template->create({
            name => 'Generic Bug',
            description => 'This is a basic template for generic bug',
            content => <<'CONTENT' });
    Steps:
    1. ...

    Expected:
    ...

    Actual:
    ...
    CONTENT

=head1 DESCRIPTION

Database object for storing a bug template

Template is inherited from L<Bugzilla::Object>.

=head1 FIELDS

=over

=item C<name> (mutable) - Template name

=item C<description> (mutable) - Template description

=item C<is_active> (mutable) - Boolean value defining if the template is active

=item C<content> (mutable) - Template content

=back

=cut

use strict;
use warnings;

package Bugzilla::Extension::BugViewPlus::Template;

use Bugzilla::Error;
use Bugzilla::Util qw(trim);

use Scalar::Util qw(blessed);

use base qw(Bugzilla::Object);


use constant DB_TABLE => 'bvp_templates';

use constant DB_COLUMNS => qw(
    id
    name
    description
    is_active
    content
);

use constant UPDATE_COLUMNS => qw(
    name
    description
    is_active
    content
);

use constant VALIDATORS => {
    name => \&_check_name,
    is_active => \&Bugzilla::Object::check_boolean,
    description => \&_check_value,
    content => \&_check_value,
};


# Accessors
sub name            { return $_[0]->{name} }
sub description     { return $_[0]->{description} }
sub is_active       { return $_[0]->{is_active} }
sub content         { return $_[0]->{content} }

# Mutators
sub set_name        { $_[0]->set('name', $_[1]); }
sub set_description { $_[0]->set('description', $_[1]); }
sub set_is_active   { $_[0]->set('is_active', $_[1]); }
sub set_content     { $_[0]->set('content', $_[1]); }

# Validators

sub _check_name {
    my ($invocant, $value) = @_;
    my $name = trim($value);
    ThrowUserError('invalid_parameter', {
            name => 'name',
            err => 'Name must not be empty'})
        unless $name;
    if (!blessed($invocant) || lc($invocant->name) ne lc($name)) {
        ThrowUserError('invalid_parameter', {
            name => 'name',
            err => "Template with name '$name' already exists"})
            if defined Bugzilla::Extension::BugViewPlus::Template->new(
                {name => $name});
    }
    return $name;
}

sub _check_value {
    my ($invocant, $value, $field) = @_;
    $value = trim($value);
    ThrowUserError('invalid_parameter', {
            name => $field,
            err => "$field can not be empty",
        }) unless $value;
    return $value;
}

sub TO_JSON {
    my $self = shift;
    return {
        id => $self->id,
        name => $self->name,
        description => $self->description,
        content => $self->content,
    }
}

=head1 METHODS

=head2 none at the moment

=cut

1;
