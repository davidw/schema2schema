schema2schema
=============

This looks at two schema.rb files and attempts to help you figure out
how to get from A to B.

This is useful if the database has been changed manually - you can
still run `rake db:schema:dump` to get two different schema files, and
run this utility on them.

Usage
-----

    ruby schema2schema.rb ./some/schema.rb /another/schema.rb

Current limitations
-------------------

* It only tells you the names of tables that are in one schema but not
  the other.
* It won't be much use if columns change their names.