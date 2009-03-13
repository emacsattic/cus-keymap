Customize keymaps using Custom
==============================

This experimental library allows customizing keymaps using Custom.  It
uses a layout definition to display your keyboard as a table.

This means that that the keys are always aligned which they might no be on
your keyboard.  The only fix to this problem is to get a good keyboard :-)

Requirements
============

The following libraries that do not come with GNU Emacs are needed:

* _keymap-utils_ http://github.com/tarsius/keymap-utils
* _wid-keymap_ http://github.com/tarsius/wid-keymap
* _wid-table_ http://github.com/tarsius/wid-table

And Emacs has to be patched with the with the _fixed-field_ patch which
can be found at http://github.com/tarsius/emacs

BUGS
====

This library is only experimental and has a few known bugs and lot's of
missing features.

Most notably buttons below the keyboard table are somehow messed up.
When clicking on these buttons Emacs actually thinks you clicked
elsewhere.  No idea what this is about - if you fix it I will be very
thankful.

---

Best Regards,

Jonas Bernoulli <jonas@bernoul.li>
