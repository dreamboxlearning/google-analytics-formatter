==========================
Google Analytics Formatter
==========================

Reads data from the Google Analytics API and formats it so it can be pasted into another system
(e.g., MediaWiki). Currently there are specific classes for web browser and Flash version
statistics.

Requirements
------------

Build-time
~~~~~~~~~~

* `CoffeeScript`_

If you wish to use the ``Makefile`` fragment, `GNU Make`_ is required. It just gives an easy way
to compile the CoffeeScript files.

.. _CoffeeScript: http://coffeescript.org/
.. _GNU Make: https://www.gnu.org/software/make/

Run-time
~~~~~~~~

* `jQuery`_

.. _jQuery: http://jquery.com/

Basic Usage
-----------

1. `Register your application`_ with Google. (Look at the instructions for JavaScript.)
2. Copy the ``*.html.example`` files somewhere, and replace the ``.example`` extension.
3. In the HTML files, replace ``some-long-number.apps.googleusercontent.com`` with your Client ID
   from step 1.
4. View the HTML file in the location where you said it would be when you registered the app
   with Google.

.. _Register your application: https://developers.google.com/analytics/solutions/articles/hello-analytics-api#register_project

License
-------

This project is copyright 2013, `DreamBox Learning, Inc.`_, licensed under the MIT license. See
``LICENSE`` for details.

.. _DreamBox Learning, Inc.: http://www.dreambox.com/
