commute.rb
==========

Command-line application to send an SMS alert if traffic on a particular route exceeds a threshold.

##Raison d'être
I'm enjoying a commute that occasionally takes 1.5-2x the expected duration.  I put the alert in a cron job so that I can just stay a bit late instead of getting stuck in traffic.

##Requires
A Twilio account
A Bing Maps API key

##Usage

    Usage: commute.rb [options]
        -f, --from SOURCE                Specifies the number to send the SMS from
        -t, --to DESTINATION             Specifies the number to send the SMS to
        -a, --pointa ADDRESS             Specifies the starting address (e.g. 1500 Market Street Philadelphia PA)
        -b, --pointb ADDRESS             Specifies the ending address (e.g. 160 N Gulph Rd King of Prussia PA)
        -d, --duration DURATION          Specifies the commute threshold in minutes. No message will be sent unless threshold is exceeded.

A crontab entry like this one will send an alert at 5:30

    30 17 * * 1-5 /path/to/commute.rb -t '+19175551212' -a '1500 market street, philadelphia, pa' -b '160 N Gulph Rd, King of Prussia, PA' -d

##Known Bugs / Problems
There is absolutely no error handling in the app.  It's quick, dirty, and I only scanned the API docs.

##Author
Kevin Way of Sector, Inc. (http://getsector.com)
	
##License
Copyright (c) 2012, Sector, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of Sector, Inc.

