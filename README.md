# ompare
Extensible compare across two and more disconnected IRIS / Cache environments

What makes ompare different from other code comparison utilities:
1) Can compare configuration and data as well as code
 - For example: Namepsace mappings, Scheduled Tasks (The Useful columns), Productions, Lookup Tables 
3) Compare side-by-side 2,5,10 or even 20 environments that are deployed on different isolated networks
5) See a summary of *what actual thing* is different ie: Parameter, Property, Method Code, Method Signature, XData, Lookup Table, SQL View
 - Then drill down into *that thing* summary to view property, method signature or row difference.
6) See *real* functional differences in code not just formatting
  -  Ignores the order of Methods in Classes or LineLabels in Routines
  -  Ignores comments in Classes or routines
  -  Ignores irrelevant whitespace or empty lines.
  -  Ignores routine legacy formatting differences
  -  Can ignore version control strings in code
7) Extensible - Please suggest or add custom new comparitors and reuse the existing reporting framework
8) Reporting as interactive HTML application and also Excel for sharing ofline difference summaries with customers.
9) Excel Workbook - Aggregate multiple reports as summary level worsheets into a downloadedable Excel Workbook. 
10) Privacy - It is an option to profile only signatures of code and config instead of actual implementation of settings or code is sensitive.
- Where signature only the drill-down to source is not available in HTML reporting but other functionality can work.
11) Exclude system or platform code from being profiled to focus only on your prodcut or customizations.
12) Profile code once and configure multilpe reports that slice or focus on specific areas of differences.
13) Profile 2, 10 or even 50 different namespaces accross an instance with a single task.

# Client install
Excludes reporting elements of code that are need required for profiling systems

 Name | Purpose
 -------------------------------------
 ompare.Schedule | The profile utility. It can run as a scheduled task or can be run from the commandline.
 ompare.SourceHandler.Base | The base class for code or config profilers
 ompare.SourceHandler.Class | Profiles Cache / IRIS class differences
 ompare.SourceHandler.Lookup | Profiles Cache / IRIS Integration LookupTables
 ompare.SourceHandler.Mapping | Profiles the mapping configuration of Cache / IRIS Namespaces to Databases for Globals, Routines and Packages
 ompare.SourceHandler.Namespace | Profiles some general instance settings
 ompare.SourceHandler.Routine | Profiles Cache / IRIS Routines
 ompare.SourceHandler.SQLTable | Flexible profile of anything with a SQL Projection so Sheduled Tasks, Productions, List of Users etc. Pick which columns are relavents. Limit number of records. Sorted by chosen primary key.
 
# Server install
Includes all code elements.
