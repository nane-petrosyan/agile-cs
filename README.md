# Agile Control System 🖇️📍

With the rise of agile methodologies and kanban-style boards for project management, creating a VCS branch per ticket has become a common practice. 

AgileCS is a set of command line tools which will enhance your git commands with agile-related functionality.

### Usage
The two commands that are currently supported are 

- `attachTicket` - with options `-t` for the ticket URL and `-b` (optional) for your branch name. If the branch name is not specified it will default to the current branch. This command will attach you ticket URL to the specified branch.
- `openTicket` - with one option `-b` which is optional. If `-b` is not specified it will default to the current branch. This command will open the matching ticket of your branch in the system's default browser.
