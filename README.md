# Parliament Voting Records Database
This application allows an admin to upload XML files of voting results from the Parliament voting system. For laws that are passed, the admin can then connect all 3 sessions of the law's votes together and publish the law to the votes.parliament.ge website. The public can then view the voting records for passed laws by law or by parliament member.

# XML File From Parliament Voting System
The XML file is a list of all items on the agenda for one day. The following data can be found in the file:
* Date of the session (conference tag)
* List of parliament members (delegate tags)
* List of parties that members belong to (group tags)
* List of items that were on agenda (agenda tags)
* List of voting sessions for agendas that had votes (voting session tags)
* List of voting results for a voting session (voting result tags)

# Problems with the Parliament Voting System & XML File 
* The XML file contains more people than parliament members 
  * Because of this, the site currently does not automatically add people to the site. It only adds people if they have voted on a law. So if a person has not voted, they will not appear to the public.
* Sometimes a parliament member will have two records within one parliament
  * Either the ID changes or name changes
  * Website currently checks for a match by ID and name in the system - if there is no match a new member record is created, which can cause duplicates
* Member IDs can change within parliament
  * The first file for the 9th parliament had different IDs than all other files from the 9th parliament
* Voting system is not able to distinguish between being absent and abstaining
* Voting system does not allow votes to be changed (but it is allowed by law)
  * Tamaz has to go into the website and update votes by hand
* Tamaz only updates votes for laws that have been passed so it is possible that for other items that are voted on, the system does not have the final vote count
* Laws in XML file do not always include the unique ID of the law so the website cannot automatically match the law votes from the 3 sessions.

# Problems with the Website
* All laws are only in Georgian (XML file only has Georgian)
* Only passed laws are available to public 
  * All other votes are in system but not public
* No info about political parties is shown (but it is in the system)
* A member that belongs to multiple parliaments have their votes on separate pages for each parliament (instead of one page)
* No flag to indicate if law went through 3 sessions or just 1 session (it is in system)

