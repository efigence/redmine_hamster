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
