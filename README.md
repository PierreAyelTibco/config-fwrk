# config-fwrk

Configuration Management Framework:

This is a set of command-line tools to manage TIBCO BusinessWorks 6 profile files from EAR files, application code and profile files.

Changes
    2024/08/07 - Pierre Ayel
       - changed detection of application and module folders (so the name does need to end with .application)
	   - new properties added to a spreadsheet are sorted in alphabetical order
	   
    2021/05/18 - Pierre Ayel
       - import.*: All pages of a configuration spreadsheet are now use so properties can be spread on multiple pages/sheets for easier maintenance
       
    2021/04/28 - Pierre Ayel
       - export.sh: Fixed case in ANT script which would prevent export.sh to work
       - import.*: Fixed a bug which ignored column after "Description" column as environment column
      