# Contributing to Surfliner

We would love your help to make Surfliner products better.

By participating in this project, you agree to abide by the [UC Principles of
Community][principles].

## Overview

### Project Structure

The Surfliner project is structured as a monorepo. If this is a new
concept to you, please read the [monorepo documentation][monorepo] as well as
this [comparison of monorepo versus multirepo][mono-vs-multi] configuration.

This results in a _project_ which we call Surfliner, and multiple _products_
which will live in the monorepo. Examples of _products_ are `starlight` and
`lark`.

Please note the difference between our use of _project_ and _product_ as we use
this language throughout our documentation.

### Branching Strategy

We are using a [trunk-based][trunk] branching strategy. In short, this means we
have a running `master` branch, `feature` branches for new work, and tagged
releases.

If you are coming from a [gitflow][gitflow] strategy, you'll note that your
feature branches will always merge back into `master` as opposed to `develop`.

## Contributing Tasks

* Reporting Issues
* Making Changes
* Documenting Code
* Committing Changes
* Submitting Changes
* Reviewing and Merging Changes

### Reporting Issues

If you would like to submit a request for a new feature, or a change to an
existing feature of a Surfliner product, we ask that you submit that request to
our [Aha! instance][aha].

If you are reporting a bug, or are a developer or stakeholder working directly
on a Sprint, you may create issues in GitLab as needed.

If you create a ticket directly in GitLab, please make sure you add a
[label][labels] for the product the ticket is related to. For example,
`starlight` or `lark`.

### Making Changes

If you are not a Surfliner team member, you should fork the repository.

* Create a topic branch from master `git branch feature/my-feature master`
* Checkout your new branch `git checkout feature/my-feature`
* Setup your development environment as documented for the project
* Run the test suite to confirm you have a working starting point
* Make sure you have added test coverage and documentation for your changes
* Run the _whole_ test suite to ensure nothing has been accidentally broken

### Documenting Code

* All new public methods, modules, and classes should include inline documentation in [YARD](http://yardoc.org/).
  * Documentation should seek to answer the question "why does this code exist?"
* Document private / protected methods as desired.
* If you are working in a file with no prior documentation, do try to document as you gain understanding of the code.
  * If you don't know exactly what a bit of code does, it is extra likely that it needs to be documented. Take a stab at it and ask for feedback in your merge request. You can use the 'Blame' button in GitLab to identify the original developer of the code and @mention them in your comment.
  * This work greatly increases the usability of the code base and supports the on-ramping of new committers.
  * We will all be understanding of one another's time constraints in this area.
* [Getting started with YARD](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)

Here is a basic example of a documented method using YARD:
```ruby
# Converts the object into textual markup given a specific format.
#
# @param format [Symbol] the format type, `:text` or `:html`
# @return [String] the object converted into the expected format.
def to_format(format = :html)
  # format the object
end
```

### Committing Code

* Make commits that are logical and representative of a complete chunk of work.
* See ["How to Write a Git Commit Message"][commit] by Chris Beams
* Use commit prefixes for the product you are working on. Example: `git commit
  -m "starlight: add missing indexing documentation"`
* If your commit will fix or close an existing issue in GitLab, you can
  reference the issue number in the commit message. Example: `Fixes #21`. See
the [GitLab automatic issue closing page][issue-closing] for more information
and examples.
* Consider creating a [default commit template][commit-template] to make this
  process easier for you.
* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.
* When you are ready to submit a merge request

### Submitting Changes

If you are coming from primarily working in GitHub, one difference to note with
GitLab is that *Pull Requests* are now called *Merge Requests*, but they are
functionally the same.

Please read the following GitLab documentation to familiarize yourself with the
process of creating and managing a merge request:

* [How to create a merge request][merge]
* [Merge requests overview][merge-overview]

Checklist:
* Make sure your branch is up to date with `master`
    * `git checkout master`
    * `git pull --rebase`
    * `git checkout <your-branch>`
    * `git rebase master`
    * It is a good idea to run your tests again.
* If you have multiple commits in your branch, consider whether squashing some
  of those commits together would improve their logical grouping. See [Squashing
commits with rebase][rebase] for more information.

### Reviewing and Merging Changes

We are using GitLab's [AutoDevOps CI/CD platform][devops] for running a variety
of automated checks. A few of these checks will be required to pass in order for
a merge request to be reviewed:

* Auto Build
* Auto Test
* Auto Code Quality

When all of the required checks pass, then any of the active _product_ team
members may review and merge the code.

We **require** at least one _product_ team member approve the merge request,
though if there are specific people on the team you would like to review your
merge request, such as domain experts, UI/UX contributors, of members of other
_product_ teams, feel free to `@mention` or add them as an Assignee.

See the [Merge Request][merge] documentation for more details on how to assign
someone to review your MR.

It is a goal of the project to not let more than 24 hours go by without a new
Merge Request receiving a review from at least one _product_ team member. This
helps keep the cadence of code submission and review quick enough that Merge
Requests quickly end up in `master` and deployed. If you have not received a
review on your MR within this time frame, please reference the MR during daily
stand up and request a review, if you have not already done so via the user
interface as described above.

#### Things to Consider When Reviewing

First, the person contributing the code is putting themselves out there. Be mindful of what you say in a review.

* Ask clarifying questions
* State your understanding and expectations
* Provide example code or alternate solutions, and explain why

This is your chance for a mentoring moment of another developer. Take time to give an honest and thorough review of what has changed. Things to consider:

  * Does the commit message explain what is going on?
  * Does the code changes have tests? _Not all changes need new tests, some changes are refactorings_
  * Do new or changed methods, modules, and classes have documentation?
  * Does the commit contain more than it should? Are two separate concerns being addressed in one commit?
  * Does the description of the new/changed specs match your understanding of what the spec is doing?
  * Did the CI pipeline complete successfully?

If you are uncertain about the proposed changes in the Merge Request, please
provide this very valuable feedback by asking questions. It benefits the entire
team if Merge Requests are used as an opportunity to share knowledge. It is a
goal of the project to try and minimize silos of expertise. Please feel
comfortable using a Merge Request review as an opportunity to help us all meet
that goal!

If, however, you find after this dialog that you are uncertain in approving the
Merge Request, feel free to bring other contributors into the conversation by
assigning them as a reviewer or mentioning the issue in Slack or daily stand up.

#### Code Style

We attempt to follow consistent code styles throughout the project. Information about our style guide is at
[`.styles`][styles], and normally takes the form of configuration for automated linters. Suggestions for changes
to the style guide are welcome as _stand-alone_ merge requests suggesting the appropriate changes. Please describe
the motivation for the change in your commit message.

For Ruby, we have a project-wide `rubocop` configuration at [`.styles/rubocop_surfliner.yml`][rubocop].
To run automated style checks, do `bundle exec rubocop` from any product directory.

For Shell scripts, we use [Shellcheck][shellcheck].
Shellcheck can be integrated into your editor, or ran directly on the command line with the `shellcheck` binary.

[aha]: https://ucsurfliner.ideas.aha.io/
[commit-template]: https://thoughtbot.com/blog/better-commit-messages-with-a-gitmessage-template
[commit]: https://chris.beams.io/posts/git-commit/
[devops]: https://docs.gitlab.com/ee/topics/autodevops/
[gitflow]: https://nvie.com/posts/a-successful-git-branching-model/
[issue-closing]: https://docs.gitlab.com/ee/user/project/issues/automatic_issue_closing.html
[labels]: https://docs.gitlab.com/ee/user/project/labels.html#creating-labels
[merge-overview]: https://docs.gitlab.com/ee/user/project/merge_requests/index.html
[merge]: https://docs.gitlab.com/ee/gitlab-basics/add-merge-request.html
[mono-vs-multi]: http://www.gigamonkeys.com/mono-vs-multi/
[monorepo]: https://trunkbaseddevelopment.com/monorepos/
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[rebase]: https://docs.gitlab.com/ee/workflow/gitlab_flow.html#squashing-commits-with-rebase
[rubocop]: ./.styles/rubocop_surfliner.yml
[shellcheck]: https://www.shellcheck.net/
[styles]: ./.styles
[trunk]: https://trunkbaseddevelopment.com/
