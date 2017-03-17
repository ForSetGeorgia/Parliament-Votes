# Parliament Voting Records Database
This application allows an admin to upload XML files of voting results from the Parliament voting system. For laws that are passed, the admin can then connect all 3 sessions of the law's votes together and publish the law to the votes.parliament.ge website. The public can then view the voting records for passed laws by law or by parliament member.

# XML File From Parliament Voting System
The XML file [here is an example](https://votes.parliament.ge/system/upload_files/373/161118.xml) is a list of all items on the agenda for one day. The following data can be found in the file:
* Date of the session (conference tag)
* List of parliament members (delegate tags)
* List of parties that members belong to (group tags)
* List of items that were on agenda (agenda tags)
* List of voting sessions for agendas that had votes (voting session tags)
* List of voting results for a voting session (voting result tags)

# What Happens When XML File is Loaded
* All data from the file is processed and saved to the database
* Each agenda is checked to see if it is a law (has a voting session and contains one of the following prefixes: 'ერთი', 'III', 'II', 'I'). If it is a law, the following occurs:
  * sets the is law flag
  * saves the session number 
  * populates the following if it is found: registration number, law title, law description
  * sets the voting session vote summary
  * adds any new delegates to the list of unique delegates

# Updating Voting Results
By law (apparently), members can change their vote after the official vote is taken. The Parliament voting system does not allow votes to be changed so these chanegs are recorded on paper. For laws that are passed the admin can use a form to update the votes for a law.

# What Happens When Making a Law Public
* The offical Law ID has to be added manually
* If a law had 3 voting sessions, then the admin must find the first two voting sessions and connect it to the 3rd session
* If not all members have voting results for this law, they are added and marked as absent
* The voting result summary for the law is updated
* The voting result summary for each member is updated

# Problems with the Parliament Voting System & XML Files 
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
* Laws in XML file do not always include the registration number so the website cannot automatically match the law votes from the 3 sessions.

# Problems with the Website
* All laws are only in Georgian (XML file only has Georgian)
* Only passed laws are available to public 
  * All other votes are in system but not public
* No info about political parties is shown (but it is in the system)
* A member that belongs to multiple parliaments have their votes on separate pages for each parliament (instead of one page)
* No flag to indicate if law went through 3 sessions or just 1 session (it is in system)

