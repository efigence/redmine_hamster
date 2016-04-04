# Redmine Hamster [![Build Status](https://travis-ci.org/efigence/redmine_hamster.svg?branch=master)](https://travis-ci.org/efigence/redmine_hamster)

Plugin helps users to control spent time on issue.


## Requirements

Developed and tested on Redmine 3.0.3.

## Installation

1. Go to your Redmine installation's plugins/directory.
2. `git clone https://github.com/efigence/redmine_hamster`
3. run `bundle install`
4. Go back to root directory.
5. `rake redmine:plugins:migrate RAILS_ENV=production`
6. Restart Redmine.

## Usage

* Admin should define which groups will be allowed to use Hamster plugin.
* User configuration:(Not required)
  - Go to /my/account/.
  - Set your own configuration like - working hours, start parallel tasks or issue status change after start or stop.
* Go to /hamster
  - If you have any issues available, then you can start it.(For parallel start change default configuration in /my/account )
  - If you want stop, just click stop.
  - Make sure that spent time is ok(If not fix it by clicking on value), choose activity and click raport.

## API

To connect with API you have to make a request with additional header:
`X-Redmine-API-Key: users_api_key`
(e.g. `X-Redmine-API-Key: da6376b020ec96ea00bf86c41e842a40c5a817fe`) 

1. hamster/index
  * method: GET
  * params: none
2. hamster/my_issues
  * method: GET
  * params: none
3. hamster/mru
  * method: GET
  * params: none
4. hamster/my_active_hamsters
  * method: GET
  * params: none
5. hamster/my_ready_to_raport_hamsters
  * method: GET
  * params: none
6. hamster/start
  * method: POST
  * params: `issue_id: Integer` (Issue ID)
7. hamster/stop
  * method: POST
  * params: `hamster_issue_id: Integer` (Hamster ID)
8. hamster/update
  * method: PATCH
  * params:
    + `id : Integer` (Hamster ID)
    + `hamster: { spend_time: Float }` (Hash with new spend_time value)
9. hamster/delete
  * method: DELETE
  * params: `id: Integer` (Hamster ID)
10. hamster/raport_time
  * method: POST
  * params: `time_entry: { issue_id: Integer, spent_on: Date, hamster_id: Integer, hours: hamster.spend_time }` (Hash with Issue ID, date (format: yyyy-mm-dd), Hamster ID)
11. hamster_journals/hamster_journals
  * method: GET
  * params: `hamster_id: Integer` (Hamster ID)
12. hamster_journals/update
  * method: PATCH
  * params: `id: Integer, to: Date, from: Date` (HamsterJournal ID, End date, Start date) - must have `to`, `from` or both.
13. hamster_journals/delete
  * method: DELETE
  * params: `id: Integer` (HamsterJournal ID)

## License

  Redmine Hamster plugin.
  Copyright (C) 2015 Efigence S.A.

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
