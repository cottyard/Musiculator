This application is deployed at https://app-cottyard.rhcloud.com.

# Musiculator Score Notation

The tempo of a melody is the beats per minute when playing. It equals 60 / *duration of a crotchet(in seconds)*. A crotchet has the duration of one beat.



| symbol        | usage         |
| ------------- | ------------- |
| .             | do nothing 
| ~             | do nothing for a semibreve(four beats)
| 0             | deactivate keys
| 1234567CDEFG  | activate music keys
| <             | pace up by 100%. effect persists.
| >             | pace down by 50%. effect persists.
| #             | pitch up
| b             | pitch down
| +             | switch to the high-pitch octave. effect persists.
| -             | switch to the low-pitch octave. effect persists.
| =             | switch to the mid-pitch octave. effect persists.
| ( and )       | bundle a set of keys to activate within the same beat
