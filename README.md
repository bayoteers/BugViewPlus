BugViewPlus Bugzilla Extension
==============================

This extension provides several enhancements to normal bug viewing experience.

 *  Editting the bug description
 *  Shortcut link to latest comment on top of the comment list
 *  Format '< severity > #' into a bug link in comments
 *  Optional simplified bug view instead of the normal full fields editor
 *  Inline editing of bugs in bug list
 *  Simple content templates for new bug creation
 *  Add all open and closed options in advanced search bug status


Installation
------------

This extension requires [BayotBase](https://github.com/bayoteers/BayotBase)
extension, so install it first.

1.  Put extension files in

        extensions/BugViewPlus

2.  Run checksetup.pl

3.  Restart your webserver if needed (for exmple when running under mod_perl)

4.  Adjust the configuration values available in Administration > Parameters >
    BugViewPlus
