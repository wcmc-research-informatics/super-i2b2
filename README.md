README
======

This directory contains the distribution files of SUPER, a pipeline for extracting data from multiple
EHRs and importing it for use within i2b2. i2b2 is a self-service cohort discovery tool that matches
clinical investigators with patient cohorts of interest. i2b2 has the ability to support projects with
specialized cohorts for different parties. SUPER supports the SOFA approach - a way of maintaining and
creating new i2b2 projects easily using views. This version of SUPER cannot be run.


Directories
-----------

Within the SQL folder there are directories. Scripts are broken up into these directories based on functionality:

		cohort: scripts that define patient cohorts for the child projects
		demodata: scripts which add data to the parent i2b2demodata database
		imdata: scripts which define the i2b2 EMPI and associates i2b2 patient ids with defined cohorts
		index: scripts which index the source and destination tables
		mapping: scripts which integrate data from various sources into i2b2 mapping tables
		preprocessing: scripts which prep tables for other scripts


Installation and Configuration
------------------------------

SUPER requires Python 2.6, paver, and pymssql. Paver is a Python-based software project scripting tool along 
the lines of Make or Rake. It is not designed to handle the dependency tracking requirements of, for example, 
a C program. It is designed to help out with all of your other repetitive tasks (run documentation generators, 
moving files around, downloading things), all with the convenience of Python’s syntax and massive library of 
code. pymssql is a simple database interface for Python that builds on top of FreeTDS to provide a Python 
DB-API (PEP-249) interface to Microsoft SQL Server. Both can be installed with pip. SUPER also requires a 
constants.py file that defines variables for use:

		sql_file_directory
		db_username
		db_password
		db_name
		program_name
		server_addr



Version History
---------------

Version 1.0x
Released  2017-10-10

* First release on GitHub