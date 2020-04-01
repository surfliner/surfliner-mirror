# UC Project Surfliner

## Table of Contents
* [About](#about)
* [Products](#products)
  * [Lark](#lark)
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
    * [Shoreline Product Team](#shoreline-product-team)
* [Communication Channels](#communication-channels)

## About
Project Surfliner is an experimental project of the UC San Diego and UC Santa Barbara libraries to collaboratively define, create, and maintain digital library products. Project Surfliner is more than shared code, or even shared objectives. The project is the collaboration effort. It is building and leveraging the strengths, experiences, and resources of each campus partner to focus on shared concepts and products.

The collaboration is named Project Surfliner after the Amtrak route that links our institutions together.

## Products
The Project Surfliner team is collaboratively developing a number of products whose code all lives within this surfliner monorepo. All the products are also named after historic intra-California train routes.

### Lark
Lark is a shared authority control platform and API. See the [Lark README](https://gitlab.com/surfliner/surfliner/blob/master/lark/README.md) for more information. Lark was named after the Southern Pacific Lark Train that operated overnight between Los Angeles and San Francisco via San Luis Obispo from 1941 - April 1968.

### Shoreline
Shoreline is a geospatial materials platform based on GeoBlacklight.  See the [Shoreline README](https://gitlab.com/surfliner/surfliner/blob/master/shoreline/discovery/README.md) for more information.  Shoreline was named after the Southern Pacific train that ran between Los Angeles and San Francisco between 1927 and 1931.

### Starlight
Starlight is an exhibits platform based on [Spotlight](https://github.com/projectblacklight/spotlight). See the [Starlight README](https://gitlab.com/surfliner/surfliner/blob/master/starlight/README.md) for more information. Starlight was named after Southern Pacific Starlight Train that operated overnight between Los Angeles and San Francisco from October 1949 - July 1957.

## Product Deployments

### UCSB
*  **Shoreline (Staging):** [http://shoreline-staging.eks.dld.library.ucsb.edu/](http://shoreline-staging.eks.dld.library.ucsb.edu/)
*  **Shoreline (Production):** [http://shoreline.eks.dld.library.ucsb.edu/](http://shoreline.eks.dld.library.ucsb.edu/)
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
* **Project Champion**: Tim ‘Six Sigma’ Marconi, John Ajao

* **Stakeholders**: individuals who are responsible for informing the decisions that product teams make and have specific knowledge and influence that help the product. Stakeholders include:
  * User Advocates;
  * Staff;
  * Administration;
  * Peer Institutions;
  * etc...

### Team Meetings
The current workcycle runs from Wednesday, February 5 to Tuesday, March 31, 2020.  The meetings below are for this time period only.

#### Project-wide
**Project Surfliner Daily Standup**<br/> 
Daily, 10:30-10:45am (*except last day of each sprint*)<br/>
[https://ucsb.zoom.us/j/310736504](https://ucsb.zoom.us/j/310736504)<br/> 
*Purpose*: Daily meeting during the sprint to discuss ongoing work and blockers.<br/>
*Required*: Project Team<br/>

**Project Surfliner Sprint Retrospective**<br/>
Last day of each sprint, 10:30am-11:30am<br/>
[https://ucsb.zoom.us/j/447601116](https://ucsb.zoom.us/j/447601116)<br/>
*Purpose*: Meeting on the last day of the sprint to discuss how things went and what to change for future sprints.<br/>
*Required*: Project Team<br/>

#### Shoreline Product Team
**Shoreline Product Kickoff Meeting**<br/>
Wednesday, January 29, 2020 3-4:30pm<br/>
[https://ucsb.zoom.us/j/360316176](https://ucsb.zoom.us/j/360316176)<br/>
*Purpose*: Overview of upcoming work cycle and review of preparatory work done in 2019.<br/>
*Required*: Shoreline Product Owner, Tech Lead & Developers<br/>
*Optional*: Shoreline Domain Experts & Stakeholders<br/>

**Shoreline Backlog Refinement**<br/>
Initial meeting Monday January 27, 2020 1:30-3pm<br/>
Regular meetings every other Wednesday, 1-2pm (*starting February 12, 2020*)<br/>
[https://ucsb.zoom.us/j/190685321](https://ucsb.zoom.us/j/190685321)<br/>
*Purpose*: Meeting, as needed, prior to Sprint Planning to groom & prioritize tickets.<br/>
*Required*: Shoreline Product Owner & Tech Lead<br/>
*Optional*: Shoreline Developers & Domain Experts<br/>

**Shoreline Sprint Planning**<br/>
Every other Thursday, 3-4pm (*starting January 30, 2020 with a 1.5 hour meeting*)<br/>
[https://ucsb.zoom.us/j/179404826](https://ucsb.zoom.us/j/179404826)<br/>
*Purpose*: Meeting the week before the next sprint to negotiate and select tickets on that sprint.<br/>
*Required*: Shoreline Product Owner, Tech Lead & Developers<br/>
*Optional*: Shoreline Domain Experts<br/>

**Shoreline Sprint Review**<br/>
Every other Tuesday, 1:30-2:30pm (*starting February 18, 2020*)<br/>
[https://ucsb.zoom.us/j/800899979](https://ucsb.zoom.us/j/800899979)<br/>
*Purpose*: Informal meeting on the last day of the sprint to show what team has accomplished during the sprint, typically taking the form of a demo. Demos are recorded. The Product Owner & Tech Lead are responsible for demo content & ensuring the demo gets recorded and shared. Demos are public; to be briefly summarized in the following Project Surfliner Public Stand-up.<br/>
*Required*: Shoreline Product Owner & Tech Lead<br/>
*Optional*: Shoreline Developers & Domain Experts<br/>


# Communication Channels
- **Blog**: [https://surfliner.ucsd.edu](https://surfliner.ucsd.edu)

- **Slack Channel**: [http://uctech.slack.com](http://uctech.slack.com) (`#surfliner`)

- **Google Group**:
  [https://groups.google.com/a/library.ucsb.edu/forum/#!forum/surfliner](https://groups.google.com/a/library.ucsb.edu/forum/#!forum/surfliner)
  (Joining the Google Group will grant you access to the Team Drive and send an invitation to the weekly public standup.)

- **YouTube Channel**: [https://www.youtube.com/channel/UCyeydFM6pQh5SGuY7bhFoUg](https://www.youtube.com/channel/UCyeydFM6pQh5SGuY7bhFoUg)

- **Project Ideas Portal**: [https://ucsurfliner.ideas.aha.io/](https://ucsurfliner.ideas.aha.io/)
