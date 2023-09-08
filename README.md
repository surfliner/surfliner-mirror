# UC Project Surfliner

## Table of Contents
* [About](#about)
* [Products](#products)
  * [Comet](#comet)
  * [Lark](#lark)
  * [Orange Empire](#orange-empire)
  * [Shoreline](#shoreline)
  * [Starlight](#starlight)
  * [Superskunk](#superskunk)
  * [Tidewater](#tidewater)
* [Architecture](#architectue)
* [Product Deployments](#product-deployments)
  * [UCSB](#ucsb)
  * [UCSD](#ucsd)
* [Developer Setup](#developer-setup)
* [Team](#team)
  * [Team Roles](#team-roles)
  * [Team Meetings](#team-meetings)
    * [Project-wide](#project-wide)
    * [Comet Sprint Team](#comet-sprint-team)
* [Communication Channels](#communication-channels)

## About
Project Surfliner is a project of the UC San Diego and UC Santa Barbara libraries to collaboratively define, create, and maintain digital library products. Project Surfliner is more than shared code, or even shared objectives. The project is the collaboration effort. It is building and leveraging the strengths, experiences, and resources of each campus partner to focus on shared concepts and products.

The collaboration is named Project Surfliner after the [Amtrak route](https://en.wikipedia.org/wiki/Pacific_Surfliner) that links our institutions together.

## Products
The Project Surfliner team is collaboratively developing a number of products whose code all lives within this surfliner monorepo. All the products are also named after historic intra-California train routes.

### Comet
Comet is a staff-facing digital object management platform based on [Hyrax](https://hyrax.samvera.org/about/), a front-end application that provides a user interface for common repository features. See the [Comet README](https://gitlab.com/surfliner/surfliner/-/blob/trunk/comet/README.md) for more information.

_Comet was named after the Sacramento Northern Train that operated between Chico to San Francisco via Sacramento from about 1928 to 1940._

Product Owner: Gabriela Montoya (UCSD) | Tech Lead: tamsin johnson (UCSB)

### Lark
Lark is a shared authority control platform and API. See the [Lark README](https://gitlab.com/surfliner/surfliner/blob/trunk/lark/README.md) for more information.

_Lark was named after the Southern Pacific Lark Train that operated overnight between Los Angeles and San Francisco via San Luis Obispo from 1941 to April 1968._

Product Owner: Arwen Hutt (UCSD) | Tech Lead: tamsin johnson (UCSB)

### Orange Empire
Orange Empire is shared IIIF services; it uses the Cantaloupe Image Server.

_Orange Empire was named after the Pacific Electric train that operated between Los Angeles and Redlands from 1914 to 1929._

Product Owner: Michael Stuart (UCSD) | Tech Lead: Matt Critchlow (UCSD)

### Shoreline
Shoreline is a geospatial materials platform based on GeoBlacklight. See the [Shoreline README](https://gitlab.com/surfliner/surfliner/-/blob/trunk/shoreline/README.md) for more information.

_Shoreline was named after the Southern Pacific train that ran between Los Angeles and San Francisco between 1927 and 1931._

Product Owner: Amy Work (UCSD) | Tech Lead: Alexandra Dunn (UCSB)

### Starlight
Starlight is an exhibits platform based on [Spotlight](https://github.com/projectblacklight/spotlight). See the [Starlight README](https://gitlab.com/surfliner/surfliner/blob/trunk/starlight/README.md) for more information.

_Starlight was named after Southern Pacific Starlight Train that operated overnight between Los Angeles and San Francisco from October 1949 to July 1957._

Product Owner: Chrissy Rissmeyer (UCSB) | Tech Lead: Matt Critchlow (UCSD)

### Superskunk
Superskunk is [Comet's](#comet) metadata API; used by other platforms to read metadata in real time.

_Superskunk was named after the California Western Railroad, popularly called the Skunk Train ("Super Skunk"), that runs from Fort Bragg to Willits starting from 1965 to the present._

Product Owner: TBD | Tech Lead: TBD

### Tidewater
Tidewater is an OAI-PMH endpoint that uses configurable metadata.

_Tidewater was named after the Tidewater Southern Railway which was a short line railroad in Central California that ran from 1910 to 1987._

Product Owner: TBD | Tech Lead: TBD

## Architecture

![Surfliner Architecture](https://lucid.app/publicSegments/view/61e9e42f-58f6-44ca-8c4d-d03504dbbbe8/image.png) 

## Product Deployments

### UCSB
*  **Comet (Staging):** [http://manage-staging.digital.library.ucsb.edu/](http://manage-staging.digital.library.ucsb.edu/)
*  **Comet (Production):** [https://manage.digital.library.ucsb.edu/](https://manage.digital.library.ucsb.edu/)
*  **Shoreline (Staging):** [http://shoreline-staging.eks.dld.library.ucsb.edu/](http://shoreline-staging.eks.dld.library.ucsb.edu/)
*  **Shoreline (Production):** [http://geodata.library.ucsb.edu/](http://geodata.library.ucsb.edu/)
*  **Starlight (Staging):** [https://spotlight-stage.library.ucsb.edu/](https://spotlight-stage.library.ucsb.edu/)
*  **Starlight (Production):** [https://spotlight.library.ucsb.edu/](https://spotlight.library.ucsb.edu/)

### UCSD
*  **Comet (Staging):** [https://lib-comet-staging.ucsd.edu/](https://lib-comet-staging.ucsd.edu/)
*  **Comet (Production):** [https://lib-comet.ucsd.edu/](https://lib-comet.ucsd.edu/)
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
* **Subject Matter Expert (or domain expert)**: a person who is an authority in a particular area or topic. For example, an accessibility expert.

Within the Project Surfliner context, there are two types of teams:

* **Project Team**: the entire active Surfliner team, including Product Owners, Tech Leads, Developers & Subject Matter Experts for all products under active development.
* **Product Team**: the group of people currently working on a given product; including Product Owner, Tech Lead, Developers & Subject Matter Experts.

While not necessarily involved in daily development work, the project also includes these other vitality important roles:
* **Campus Project Owner (when needed)**: responsible for ensuring that the needs of their campus stakeholders are considered in the development of each product
* **Project Champion**: higher level administrators who help with resourcing, advocacy, and clearing major blockers
* **Project Sponsors**: the University Librarian for each campus partner
* **Stakeholders**: individuals who are responsible for informing the decisions that product teams make and have specific knowledge and influence that help the product. Stakeholders include:
  * User Advocates;
  * Staff;
  * Administration;
  * Peer Institutions;
  * etc...

### Team Meetings
All Surfliner sprints include a mix of project-wide and per product team meetings.

#### Project-wide
**Project Surfliner Daily Standup**<br/>
Daily except last day of each sprint<br/>
*Purpose*: Daily meeting during the sprint to discuss ongoing work and blockers.<br/>
*Required*: Project Team<br/>

**Project Surfliner Sprint Review Planning**<br/>
Last day of each sprint<br/>
*Purpose*: Brief meeting on the last day of the sprint to plan for the demo. The Product Owner(s) & Tech Lead(s) for products in sprint are responsible for demo content & ensuring the demo gets recorded and shared.<br/>
*Required*: Product Owner(s) & Tech Lead(s) for products in sprint<br/>
*Optional*: Project Team<br/>

**Project Surfliner Sprint Review**<br/>
Last day of each sprint<br/>
*Purpose*: Informal meeting on the last day of the sprint to show what the product team(s) has accomplished during the sprint, typically taking the form of a demo. Demos are recorded.<br/>
*Required*: Product Owner(s) & Tech Lead(s) for products in sprint, Subject Matter Experts, and stakeholders<br/>
*Optional*: Project Team<br/>

**Project Surfliner Sprint Retrospective**<br/>
Last day of each sprint<br/>
*Purpose*: Meeting on the last day of the sprint to discuss how things went and what to change for future sprints.<br/>
*Required*: Project Team<br/>

#### Product Team
**Backlog Refinement**<br/>
*Purpose*: Meeting, as needed, prior to Sprint Planning to refine & prioritize tickets.<br/>
*Required*: Product Owner, Tech Lead<br/>
*Optional*: other Developers, Subject Matter Experts, stakeholders<br/>

**Sprint Planning**<br/>
*Purpose*: Meeting the week before the next sprint to negotiate and select tickets on that sprint.<br/>
*Required*: Product Owner and Tech Lead plus Product Team Developers<br/>
*Optional*: Subject Matter Experts<br/>

### Meeting Schedules for the Current Work Cycle
The current workcycle runs from Wednesday, September 6, 2023 to Tuesday, November 11, 2023.  The meetings below are for this time period only.

#### Project-wide
**Project Surfliner Daily Standup**<br/>
Daily, 10:30-10:45am (*except last day of each sprint*)<br/>
[https://ucsb.zoom.us/j/310736504](https://ucsb.zoom.us/j/310736504)<br/>

**Project Surfliner Sprint Review Planning**<br/>
Last day of each sprint, 10:30-10:45am<br/>
[https://ucsd.zoom.us/j/5296465230](https://ucsd.zoom.us/j/5296465230)<br/>

**Project Surfliner Sprint Review**<br/>
Last day of each sprint, 10:45-11:30am<br/>
[https://ucsd.zoom.us/j/5296465230](https://ucsd.zoom.us/j/5296465230)<br/>

**Project Surfliner Sprint Retrospective**<br/>
Day after each sprint, 1:00-2:00pm<br/>
[https://ucsb.zoom.us/j/99140390905](https://ucsb.zoom.us/j/99140390905)<br/>

#### Comet Sprint Team
**Backlog Refinement**<br/>
TBD<br/>
[https://ucsd.zoom.us/j/5296465230](https://ucsd.zoom.us/j/5296465230)<br/>

**Sprint Planning**<br/>
Every other Monday, 1:00-2:00pm<br/>
[https://ucsd.zoom.us/j/5296465230](https://ucsd.zoom.us/j/5296465230)<br/>

#### Shoreline Sprint Team
**Backlog Refinement**<br/>
Every other Friday, 11:00am-12:00pm<br/>
[https://ucsd.zoom.us/j/98011540957](https://ucsd.zoom.us/j/98011540957)<br/>

**Sprint Planning**<br/>
Every other Monday, 1:00-2:00pm<br/>
[https://ucsd.zoom.us/j/98011540957](https://ucsd.zoom.us/j/98011540957)<br/>

# Communication Channels
- **Blog**: [https://surfliner.ucsd.edu](https://surfliner.ucsd.edu)
- **Slack Channel**: [http://uctech.slack.com](http://uctech.slack.com) (`#surfliner`)
- **Google Group**:
  [https://groups.google.com/a/library.ucsb.edu/forum/#!forum/surfliner](https://groups.google.com/a/library.ucsb.edu/forum/#!forum/surfliner)
  (Joining the Google Group will grant you access to the Team Drive)
- **YouTube Channel**: [https://www.youtube.com/channel/UCyeydFM6pQh5SGuY7bhFoUg](https://www.youtube.com/channel/UCyeydFM6pQh5SGuY7bhFoUg)
