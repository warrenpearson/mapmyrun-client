# mapmyrun-client
A ruby client for accessing the MayMyRun "You VS the Year" stats.

Given your total distance run for the year, the script will return your current 
position with some context about the people around you (which is hard to get via
the website):

````
./map_my_run_client.rb 5.24

10 requests
http://www.mapmyrun.com/leaderboard/challenge_aeXPR2rxP4_overall/page/125/?per_page=20
Total count: 23119
...
2494. Warren Pearson: 1 workout, 5.24km <<<<<
````

You can also supply your expected total distance for the coming days, and see
how that affects your place:

````
./map_my_run_client.rb 10.12 <anything>

4 requests
http://www.mapmyrun.com/leaderboard/challenge_aeXPR2rxP4_overall/page/38/?per_page=20
Total count: 23119
...
744. xxxx xxxxx: 1 workout, 10.13km 
745. xxxx xxxxxx: 1 workout, 10.12km 
````

### N.B.

The script makes an effort to limit the number of requests it makes (out of respect for the MapMyRun infrastructure), but it's not very smart.

Originally written for You VS The Year 2017.

Updated for 2018.
