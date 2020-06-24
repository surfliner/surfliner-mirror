# UC Project Surfliner

## Table of Contents
* [About](#about)
* [Products](#products)
  * [Comet](#comet)
  * [Lark](#lark)
  * [Orange Empire](#orange-empire)
  * [Shoreline](#shoreline)
  * [Starlight](#starlight)
* [Product Deployments](#product-deployments)
  * [UCSB](#ucsb)
  * [UCSD](#ucsd)
* [Developer Setup](#developer-setup)
* [Team](#team)
  * [Team Roles](#team-roles)
  * [Team Meetings](#team-meetings)
    * [Project-wide](#project-wide)
    * [DevOps Sprint Team](#devops-sprint-team)
    * [Shoreline Product Team](#shoreline-product-team)
* [Communication Channels](#communication-channels)

## About
Project Surfliner is an experimental project of the UC San Diego and UC Santa Barbara libraries to collaboratively define, create, and maintain digital library products. Project Surfliner is more than shared code, or even shared objectives. The project is the collaboration effort. It is building and leveraging the strengths, experiences, and resources of each campus partner to focus on shared concepts and products.

The collaboration is named Project Surfliner after the Amtrak route that links our institutions together.

## Products
The Project Surfliner team is collaboratively developing a number of products whose code all lives within this surfliner monorepo. All the products are also named after historic intra-California train routes.

### Comet
Comet is a staff facing digital objects management platform. (More information coming soon!) Comet was named after the Sacramento Northern	Train that operated between Chico to San Francisco via Sacramento from about 1928 to 1940.

### Lark
Lark is a shared authority control platform and API. See the [Lark README](https://gitlab.com/surfliner/surfliner/blob/trunk/lark/README.md) for more information. Lark was named after the Southern Pacific Lark Train that operated overnight between Los Angeles and San Francisco via San Luis Obispo from 1941 - April 1968.

### Orange Empire
Orange Empire is are shared IIIF services (so not really a product). Orange Empire was named after the Pacific Electric train that operated between L.A. and Redlands from 1914-1929

### Shoreline
Shoreline is a geospatial materials platform based on GeoBlacklight.  See the [Shoreline README](https://gitlab.com/surfliner/surfliner/blob/trunk/shoreline/discovery/README.md) for more information.  Shoreline was named after the Southern Pacific train that ran between Los Angeles and San Francisco between 1927 and 1931.

### Starlight
Starlight is an exhibits platform based on [Spotlight](https://github.com/projectblacklight/spotlight). See the [Starlight README](https://gitlab.com/surfliner/surfliner/blob/trunk/starlight/README.md) for more information. Starlight was named after Southern Pacific Starlight Train that operated overnight between Los Angeles and San Francisco from October 1949 - July 1957.

## Product Deployments

### UCSB
*  **Shoreline (Staging):** [http://shoreline-staging.eks.dld.library.ucsb.edu/](http://shoreline-staging.eks.dld.library.ucsb.edu/)
*  **Shoreline (Production):** [http://geodata.library.ucsb.edu/](http://geodata.library.ucsb.edu/)
*  **Starlight (Staging):** [https://spotlight-stage.library.ucsb.edu/](https://spotlight-stage.library.ucsb.edu/)
*  **Starlight (Production):** [https://spotlight.library.ucsb.edu/](https://spotlight.library.ucsb.edu/)

### UCSD
*  **Shoreline (Staging):** [http://geodata-staging.ucsd.edu](http://geodata-staging.ucsd.edu)
*  **Shoreline (Production):** [http://geodata.ucsd.edu](http://geodata.ucsd.edu)
*  **Starlight (Staging):** [https://exhibits-staging.ucsd.edu/](https://exhibits-staging.ucsd.edu/)
*  **Starlight (Production):** [https://exhibits.ucsd.edu/](https://exhibits.ucsd.edu/)

## Developer Setup
* Start by getting yourself an account on GitLab.
* Once you have that, be sure to [add an SSH key to your GitLab account](https://docs.gitlab.com/ee/ssh/#adding-an-ssh-key-to-your-gitlab-account)
* Change to your working directory for new projects `cd .`
* Clone Surfliner's monorepo `git@gitlab.com:surfliner/surfliner.git`
* Change to the application directory `cd surfliner`
* For product specific setup see individual project README.md

## Team

### Team Roles
Surfliner development follows two-week sprint cycles that include both the Santa Barbara and San Diego teams for all products. The following team roles have been identified:

* **Product Owner**: represents the user community and is responsible for working with the user group to determine what features will be in the product release.
* **Tech Lead**: the technical lead is responsible for the technical decision making on a given product; they provide facilitation and direction to guide development and architectural decisions.
* **Developer**: an individual that builds and create software and applications.
* **Domain Expert**: a person who is an authority in a particular area or topic. For example, an accessibility expert.

Within the Project Surfliner context, there are two types of teams:

* **Project Team**: the entire active Surfliner team, including Product Owners, Tech Leads, Developers & Domain Experts for all products under active development.
* **Product Team**: the group of people currently working on a given product; including Product Owner, Tech Lead, Developers & Domain Experts.

While not involved in daily development work, the project also includes these two other vitality important roles:
* **Project Champion**: higher level administrators who help with resourcing, advocacy, and clearing major blockers
* **Project Sponsors**: the University Librarian for each campus partner 
* **Stakeholders**: individuals who are responsible for informing the decisions that product teams make and have specific knowledge and influence that help the product. Stakeholders include:
  * User Advocates;
  * Staff;
  * Administration;
  * Peer Institutions;
  * etc...

### Team Meetings
The current workcycle runs from Wednesday, June 17 to Tuesday, August 11, 2020.  The meetings below are for this time period only.

#### Project-wide
**Project Surfliner Daily Standup**<br/> 
Daily, 10:30-10:45am (*except last day of each sprint*)<br/>
[https://ucsb.zoom.us/j/310736504](https://ucsb.zoom.us/j/310736504)<br/> 
*Purpose*: Daily meeting during the sprint to discuss ongoing work and blockers.<br/>
*Required*: Project Team<br/>

**Project Surfliner Sprint Retrospective**<br/>
Last day of each sprint, 2:00-3:00pm<br/>
[https://ucsb.zoom.us/j/99140390905](https://ucsb.zoom.us/j/99140390905)<br/> 
*Purpose*: Meeting on the last day of the sprint to discuss how things went and what to change for future sprints.<br/>
*Required*: Project Team<br/>

#### DevOps Sprint Team
**DevOps Backlog Refinement**<br/>
Regular meetings every other Monday, 11am-12pm (*starting June 22, 2020*)<br/>
[https://ucsb.zoom.us/j/91321846191](https://ucsb.zoom.us/j/91321846191)<br/>
*Purpose*: Meeting, as needed, prior to Sprint Planning to refine & prioritize tickets.<br/>
*Required*: Shoreline/Starlight Tech Leads<br/>
*Optional*: Shoreline/Starlight Product Owners, other Tech Leads & DevOps Sprint Team Developers<br/>

**DevOps Sprint Planning**<br/>
Initial meeting Tuesday June 16, 2020, 11am-12pm<br/>
Regular meetings every other Monday, 11am-12pm (*starting June 29, 2020*)<br/>
[https://ucsb.zoom.us/j/97113833320](https://ucsb.zoom.us/j/97113833320)<br/>
*Purpose*: Meeting the week before the next sprint to negotiate and select tickets on that sprint.<br/>
*Required*: Shoreline/Starlight Tech Leads plus DevOps Sprint Team Developers<br/>
*Optional*: Shoreline/Starlight Product Owners, other Tech Leads<br/>

**DevOps Sprint Review**<br/>
Last day of each sprint, 10:30-11:30am (*starting June 30, 2020*)<br/>
[https://ucsb.zoom.us/j/91659880579](https://ucsb.zoom.us/j/91659880579)<br/>
*Purpose*: Informal meeting on the last day of the sprint to show what team has accomplished during the sprint, typically taking the form of a demo. Demos are recorded. The Product Owner & Tech Lead are responsible for demo content & ensuring the demo gets recorded and shared.<br/>
*Required*: Shoreline/Starlight Tech Leads<br/>
*Optional*: Shoreline/Starlight Product Owners & DevOps Sprint Team Members<br/>

#### Shoreline Product Team
Shoreline sprints during this workcycle are focused on planning for upcoming development work. 

**Shoreline Backlog Refinement**<br/>
Initial meeting Monday June 15, 2020, 11am-12pm<br/>
Regular meetings every other Tuesday, 3-4pm (*starting June 23, 2020*)<br/>
[https://ucsb.zoom.us/j/190685321](https://ucsb.zoom.us/j/190685321)<br/>
*Purpose*: Meeting, as needed, prior to Sprint Planning to groom & prioritize tickets.<br/>
*Required*: Shoreline Product Owner & Domain Experts<br/>
*Optional*: Shoreline Tech Lead<br/>

**Shoreline Sprint Planning**<br/>
Initial meeting Tuesday June 16, 2020, 3-4pm<br/>
Regular meetings every other Wednesday, 11am-12pm (*starting June 24, 2020*)<br/>
[https://ucsb.zoom.us/j/179404826](https://ucsb.zoom.us/j/179404826)<br/>
*Purpose*: Meeting the week before the next sprint to negotiate and select tickets on that sprint.<br/>
*Required*: Shoreline Product Owner & Domain Experts<br/>
*Optional*: Shoreline Tech Lead<br/>

**Shoreline Sprint Review**<br/>
Last day of each sprint, 10:30-11am (*starting June 30, 2020*)<br/>
[https://ucsb.zoom.us/j/800899979](https://ucsb.zoom.us/j/800899979)<br/>
*Purpose*: Informal meeting on the last day of the sprint to show what team has accomplished during the sprint, typically taking the form of a demo. Demos are recorded. The Product Owner & Tech Lead are responsible for demo content & ensuring the demo gets recorded and shared.<br/>
*Required*: Shoreline Product Owner<br/>
*Optional*: Shoreline Tech Lead & Domain Experts<br/>

# Communication Channels
- **Blog**: [https://surfliner.ucsd.edu](https://surfliner.ucsd.edu)
- **Slack Channel**: [http://uctech.slack.com](http://uctech.slack.com) (`#surfliner`)
- **Google Group**:
  [https://groups.google.com/a/library.ucsb.edu/forum/#!forum/surfliner](https://groups.google.com/a/library.ucsb.edu/forum/#!forum/surfliner)
  (Joining the Google Group will grant you access to the Team Drive)
- **YouTube Channel**: [https://www.youtube.com/channel/UCyeydFM6pQh5SGuY7bhFoUg](https://www.youtube.com/channel/UCyeydFM6pQh5SGuY7bhFoUg)