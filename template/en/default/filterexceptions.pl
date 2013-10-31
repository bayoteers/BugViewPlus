# -*- Mode: perl; indent-tabs-mode: nil -*-

%::safe = (

'hook/bug/edit-after_custom_fields.html.tmpl' => [
  'bug.bug_id',
  'bug.votes',
],

'hook/bug/comments-aftercomments.html.tmpl' => [
  "d == '0' ? ':first' : ':last'",
],

'hook/admin/admin-end_links_right.html.tmpl' => [
  'class',
]

);
